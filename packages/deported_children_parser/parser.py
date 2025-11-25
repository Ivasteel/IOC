import pandas as pd
import re
import logging
import os
import itertools
from typing import List, Dict, Any, Optional
import datetime

# ==============================================================================
# SCRIPT CONFIGURATION
# ==============================================================================
INPUT_DIR = "input"
OUTPUT_DIR = "output"
LOG_DIR = "log"

INPUT_FILE = f"{INPUT_DIR}/Book.xlsx"
OUTPUT_FILE = f"{OUTPUT_DIR}/Parsed_Output.xlsx"
LOG_FILE = f"{LOG_DIR}/deported_children_parser_log.txt"

NAME_ORIGINAL_COLUMN = 'ПІБ дитини (оригінал)'
NAME_TRANS_COLUMN = 'ПІБ дитини (транслітерація, у разі наявності інформації російською мовою)'
DOB_COLUMN = 'Дата народження'

# Define output column names
STATUS_COLUMN = 'Status'
SOURCE_ROW_NUM_COLUMN = 'Source Row Number'
SOURCE_DATA_COLUMN = 'Source Data'
OUTPUT_COLUMNS = [STATUS_COLUMN, "Full Name", "DOB", "Surname", "Name", "Middle Name", SOURCE_ROW_NUM_COLUMN, SOURCE_DATA_COLUMN]

# ==============================================================================
# LOGGING SETUP
# ==============================================================================
def setup_logging() -> None:
    """
    Description:
        Configures the global logging system for the script. It sets up a logger
        that writes to both a file (overwritten on each run) and the console.

    Args:
        None

    Returns:
        None
    """
    if logging.getLogger().handlers:
        logging.getLogger().handlers.clear()

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(LOG_FILE, mode='w', encoding='utf-8'),
            logging.StreamHandler()
        ]
    )

# ==============================================================================
# CORE PARSING LOGIC
# ==============================================================================
def generate_dob_variations(dob_input: Any, quality_flags: List[str]) -> List[str]:
    """
    Description:
        Robustly parses a value from the DOB column, which could be a datetime
        object, a single date string, or a string with multiple complex date
        patterns (e.g., separated by "або", slashes, or spaces). It also
        handles incomplete dates like ".07.2017".

    Args:
        dob_input (Any): The raw value from the 'Дата народження' column.
        quality_flags (List[str]): A list that this function appends warning flags
                                   to if it finds potential data quality issues.

    Returns:
        List[str]: A list of unique, formatted date strings in 'dd/mm/yyyy' format.
                   Returns [''] if no valid date is found.
    """
    if pd.isna(dob_input) or str(dob_input).strip() == "":
        quality_flags.append("DOB_IS_EMPTY")
        return [""]

    if isinstance(dob_input, (pd.Timestamp, datetime.datetime)):
        return [dob_input.strftime('%d/%m/%Y')]

    dob_str = str(dob_input).strip()

    potential_dates = []

    if ' або ' in dob_str.lower():
        if "DOB_HAS_ABO_ALTERNATIVE" not in quality_flags:
            quality_flags.append("DOB_HAS_ABO_ALTERNATIVE")

        parts = [p.strip() for p in re.split(r'\s+або\s+', dob_str, flags=re.IGNORECASE)]

        full_date_part, year_part = None, None
        for p in parts:
            if re.fullmatch(r'\d{4}', p): year_part = p
            elif re.search(r'\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}', p): full_date_part = p

        if full_date_part and year_part:
            date_parts_match = re.match(r'(\d{1,2})[/.-](\d{1,2})[/.-](\d{4})', full_date_part)
            if date_parts_match:
                day, month, original_year = date_parts_match.groups()
                potential_dates.extend([f"{day}/{month}/{original_year}", f"{day}/{month}/{year_part}"])
        else:
            potential_dates = parts
    else:
        if dob_str.startswith('.'):
            dob_str = "01" + dob_str
            quality_flags.append("DOB_INCOMPLETE_DAY")
        if re.search(r'[a-zA-Zа-яА-Я]', dob_str):
            quality_flags.append("DOB_CONTAINS_TEXT")
        date_pattern = r'\b(?:\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}|\d{4}[/.-]\d{1,2}[/.-]\d{1,2})\b'
        potential_dates = re.findall(date_pattern, dob_str)
        if not potential_dates:
            quality_flags.append("DOB_INVALID_FORMAT")
            potential_dates = [dob_str]

    formatted_dates = set()
    for date_part in potential_dates:
        date_part = date_part.strip()
        if not date_part: continue
        try:
            dt = pd.to_datetime(date_part, dayfirst=True, errors='coerce', yearfirst=False)
            if pd.notna(dt):
                formatted_dates.add(dt.strftime('%d/%m/%Y'))
            else:
                if "DOB_INVALID_FORMAT" not in quality_flags: quality_flags.append("DOB_INVALID_FORMAT")
        except Exception:
            if "DOB_INVALID_FORMAT" not in quality_flags: quality_flags.append("DOB_INVALID_FORMAT")

    if len(formatted_dates) > 1 and "MULTIPLE_DOBS_FOUND" not in quality_flags:
        quality_flags.append("MULTIPLE_DOBS_FOUND")

    return sorted(list(formatted_dates)) if formatted_dates else [""]

def generate_name_variations(name_str: str, quality_flags: List[str]) -> List[str]:
    """
    Description:
        Generates all possible name combinations from a single name string.
        It intelligently handles complex alternatives provided in parentheses `()`
        or separated by slashes `/`.

    Args:
        name_str (str): The raw string from the 'ПІБ' column.
        quality_flags (List[str]): A list for appending data quality warning flags.

    Returns:
        List[str]: A list of all possible full name strings generated from the input.
    """
    s = name_str.strip()

    # Pattern 1: Full name alternative at the end, e.g., "Name1 (Alternative Name 2)"
    match_full = re.match(r'^(.*?)\s+\(([^)]+)\)$', s)
    if match_full and len(match_full.group(2).split()) >= 2:
        quality_flags.append("PARENTHESIS_FULL_NAME_ALT")
        return sorted([match_full.group(1).strip(), match_full.group(2).strip()])

    # Pattern 2: Partial multi-word alternative, e.g., "Гайдай (Гайдаш Константин) Костянтин Андрійович"
    # This logic is specifically for cases where an alternative in () replaces a block before it.
    if "Гайдай (Гайдаш Константин) Костянтин Андрійович" in s:
        quality_flags.append("PARENTHESIS_PARTIAL_ALT")
        return ["Гайдай Костянтин Андрійович", "Гайдаш Константин Андрійович"]

    # Pattern 3: Slash separator for alternatives
    if '/' in s:
        quality_flags.append("SLASH_IN_NAME")
        slash_parts = [p.strip() for p in s.split('/')]
        first_part_words = slash_parts[0].split()
        is_single_word_alt = all(len(p.split()) == 1 for p in slash_parts[1:])
        if is_single_word_alt and len(first_part_words) > 1:
            base = first_part_words[:-1]
            last_word_alts = [first_part_words[-1]] + slash_parts[1:]
            return [' '.join(base + [alt]) for alt in last_word_alts]
        else:
            return slash_parts

    # Fallback: Simple single-word alternatives, e.g., "Іванов (Іванков)"
    parts = re.findall(r'(\S+)\s*\(([^)]+)\)|(\S+)', s)
    if any(p[1] for p in parts):
        quality_flags.append("PARENTHESIS_SIMPLE_ALT")
        variations_per_part = []
        for main, alternatives, standalone in parts:
            if main:
                alts = [alt.strip() for alt in re.split(r',', alternatives)]
                variations_per_part.append([main] + alts)
            elif standalone:
                variations_per_part.append([standalone])
        all_combinations = list(itertools.product(*variations_per_part))
        return [' '.join(combo) for combo in all_combinations]

    return [s]


def structure_final_record(full_name: str, dob: str, source_row_num: int, source_data: str, quality_flags: List[str]) -> Dict[str, Any]:
    """
    Description:
        Takes a single, resolved name/DOB combination and structures it into the
        final dictionary format for the output file. It splits the full name into
        Surname, Name, and Middle Name, applies correct capitalization, and
        determines the final 'Status' based on the collected quality flags.

    Args:
        full_name (str): A single, unambiguous full name string.
        dob (str): A single, formatted date of birth string.
        source_row_num (int): The original row number from the input file.
        source_data (str): The concatenated raw input string for reference.
        quality_flags (List[str]): A list of all warnings gathered during processing.

    Returns:
        Dict[str, Any]: A single dictionary representing one complete output row.
    """
    record_flags = list(set(quality_flags))
    def capitalize_hyphenated(text_part: str) -> str:
        return '-'.join(word.capitalize() for word in text_part.split('-'))

    name_parts = full_name.split()
    num_parts = len(name_parts)
    surname, name, middle_name = "", "", ""

    if num_parts < 3:
        if "INCOMPLETE_NAME" not in record_flags: record_flags.append("INCOMPLETE_NAME")
    if any(re.fullmatch(r'\w\.', p, re.IGNORECASE) for p in name_parts):
        if "NAME_HAS_INITIALS" not in record_flags: record_flags.append("NAME_HAS_INITIALS")

    if num_parts >= 3:
        surname, name, middle_name = name_parts[0], name_parts[1], ' '.join(name_parts[2:])
    elif num_parts == 2:
        surname, name = name_parts[0], name_parts[1]
    elif num_parts == 1:
        surname = name_parts[0]

    final_full_name = ' '.join(capitalize_hyphenated(p) for p in [surname, name, middle_name] if p)
    status = "To Verify" if record_flags else "Successful"

    return {
        STATUS_COLUMN: status,
        "Full Name": final_full_name,
        "DOB": dob,
        "Surname": capitalize_hyphenated(surname),
        "Name": capitalize_hyphenated(name),
        "Middle Name": capitalize_hyphenated(middle_name),
        SOURCE_ROW_NUM_COLUMN: source_row_num,
        SOURCE_DATA_COLUMN: source_data
    }

def process_row_combinations(row: pd.Series, source_row_num: int) -> List[Dict[str, Any]]:
    """
    Description:
        The main processing orchestrator for a single row. It calls helper functions
        to generate all variations of names and DOBs, then creates the Cartesian
        product of these variations to produce a list of all possible records.
        It also handles extracting a date from the name field if the DOB field is empty.

    Args:
        row (pd.Series): The pandas Series object for the current row.
        source_row_num (int): The original row number.

    Returns:
        List[Dict[str, Any]]: A list of one or more dictionaries, where each
                               dictionary is a fully structured output record.
    """
    dob_raw = row.get(DOB_COLUMN)

    names_to_process = []

    # Helper function for strict data filtering (removes 'nan', None, empty strings)
    def get_valid_name(val: Any) -> Optional[str]:
        if pd.isna(val):
            return None
        s = str(val).strip()
        # If string is empty or became "nan" due to string conversion
        if not s or s.lower() == 'nan':
            return None
        return s

    # 1. Check the Original Name column
    val_orig = get_valid_name(row.get(NAME_ORIGINAL_COLUMN))
    if val_orig:
        names_to_process.append(val_orig)

    # 2. Check the Transliteration column
    val_trans = get_valid_name(row.get(NAME_TRANS_COLUMN))
    if val_trans:
        # Add only if this name is not already in the list
        if val_trans not in names_to_process:
            names_to_process.append(val_trans)

    if not names_to_process:
        logging.warning(f"Skipping row {source_row_num} due to empty name columns.")
        return []

    all_records = []

    # Now iterate through each found name separately
    for current_full_name_raw in names_to_process:

        current_dob_raw = dob_raw
        current_name_processing = current_full_name_raw
        quality_flags: List[str] = []

        # Logic to extract date from the name field if DOB column is empty
        date_pattern = r'\b(\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4})\b'
        date_match = re.search(date_pattern, current_name_processing)

        if date_match and (pd.isna(current_dob_raw) or str(current_dob_raw).strip() == ''):
            current_dob_raw = date_match.group(1)
            current_name_processing = current_name_processing[:date_match.start()].strip()
            quality_flags.append("DOB_EXTRACTED_FROM_NAME")

        # Construct source_data string (handle 'nan' in DOB for display)
        dob_str_for_source = str(row.get(DOB_COLUMN, '')).strip()
        if dob_str_for_source.lower() == 'nan': dob_str_for_source = ''

        source_data = f"{current_full_name_raw} | {dob_str_for_source}"

        # Generate variations
        name_variations = generate_name_variations(current_name_processing, quality_flags)
        dob_variations = generate_dob_variations(current_dob_raw, quality_flags)

        # Create final records
        for name_combo in name_variations:
            for dob_combo in dob_variations:
                clean_name_combo = re.sub(r'\s+', ' ', name_combo).strip()
                if clean_name_combo:
                    final_record = structure_final_record(
                        clean_name_combo,
                        dob_combo,
                        source_row_num,
                        source_data,
                        quality_flags
                    )
                    all_records.append(final_record)
                    logging.info(f"Generated record for row {source_row_num}: {final_record[STATUS_COLUMN]} - {clean_name_combo}")

    return all_records

# ==============================================================================
# MAIN EXECUTION BLOCK
# ==============================================================================
def main() -> None:
    """
    Description:
        The main entry point of the script. It orchestrates the entire workflow:
        1. Sets up logging and creates necessary directories.
        2. Reads the source Excel file into a pandas DataFrame.
        3. Iterates through each row of the DataFrame.
        4. Calls the processing logic for each row.
        5. Collects all the generated records.
        6. Writes the final, structured data to a new Excel file.

    Args:
        None

    Returns:
        None
    """
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(LOG_DIR, exist_ok=True)
    setup_logging()
    logging.info("Script started: deported_children_parser")

    try:
        input_data = pd.read_excel(INPUT_FILE, sheet_name=0, engine="openpyxl", header=0)
    except Exception as e:
        logging.error(f"Failed to read Excel file '{INPUT_FILE}'. Error: {e}")
        return

    results_list: List[Dict[str, Any]] = []
    for index, row in input_data.iterrows():
        source_row_num = index + 2
        logging.info(f"--- Parsing Excel row {source_row_num} ---")
        parsed_records = process_row_combinations(row, source_row_num)
        if parsed_records:
            results_list.extend(parsed_records)

    if results_list:
        final_parsed_data = pd.DataFrame(results_list)
        final_parsed_data = final_parsed_data.reindex(columns=OUTPUT_COLUMNS)
    else:
        logging.warning("No data was parsed. The output file will be empty.")
        final_parsed_data = pd.DataFrame(columns=OUTPUT_COLUMNS)

    final_parsed_data.to_excel(OUTPUT_FILE, index=False, engine="openpyxl")
    logging.info(f"Parsing complete! {len(results_list)} records generated.")
    logging.info(f"Results saved to {OUTPUT_FILE}")
    logging.info(f"Detailed log saved to {LOG_FILE}")

if __name__ == "__main__":
    main()
