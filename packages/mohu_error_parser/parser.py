import pandas as pd
import re
import logging
import os
from typing import List, Dict, Any, Optional

# ==============================================================================
# SCRIPT CONFIGURATION
# All main settings are here for easy access and modification.
# ==============================================================================
INPUT_DIR = "input"
OUTPUT_DIR = "output"
LOG_DIR = "log"

INPUT_FILE = f"{INPUT_DIR}/Book.xlsx"
OUTPUT_FILE = f"{OUTPUT_DIR}/Parsed_Output.xlsx"
LOG_FILE = f"{LOG_DIR}/parsing_log.txt"
SHEET_NAME = "Data_pomylky"

# Define primary and fallback columns for parsing
PRIMARY_COLUMN = 'Помилки'
FALLBACK_COLUMN = 'Коментарі'

# Name for the new column that will store the source row number
SOURCE_ROW_COLUMN = 'Source Row'

# ==============================================================================
# CENTRALIZED LIST OF PARSING RULES
# To add a new rule, simply add a new dictionary to this list.
# Order is important: more specific rules must come BEFORE more general ones.
# ==============================================================================
PARSING_PATTERNS = [
    {
        "name": "FULL",
        "regex": r'(\d{6})\s*;?[\s]*(.*?)\s*ORA-\d+.*ІПН\s*\[([\d]+)[}\]]?\s*.*?СРКО\s*\[([\d]+)\]',
        "mapping": {"Code": 1, "Error Description": 2, "IPN": 3, "SRKO": 4},
        "defaults": {},
        "post_process": lambda r: {**r, "Error Description": r["Error Description"].strip() + " ORA-20000"}
    },
    {
        "name": "OPERATION_CODE",
        "regex": r'(\d{6})\s*;?[\s]*(Недостовірний код операції для нарахувань),?\s*ІПН\s*\[([\d]+)\][\.]?',
        "mapping": {"Code": 1, "Error Description": 2, "IPN": 3},
        "defaults": {"SRKO": "N/A"}
    },
    {
        "name": "PARTIAL",
        "regex": r'(\d{6})\s*;?[\s]*(.*ORA-\d+:.*?)',
        "mapping": {"Code": 1, "Error Description": 2},
        "defaults": {"IPN": "N/A", "SRKO": "N/A"}
    },
    {
        "name": "NO_CODE_FULL",
        "regex": r'^(.*?)\s*ORA-\d+.*?ІПН\s*\[(\d+)\].*?СРКО\s*\[(\d+)\].*',
        "mapping": {"Error Description": 1, "IPN": 2, "SRKO": 3},
        "defaults": {"Code": "N/A"},
        "post_process": lambda r: {
            **r,
            "Error Description": ("Некоректні вхідні данні" if not r["Error Description"].strip() else r["Error Description"].strip()) + " ORA-20000"
        }
    },
    {
        "name": "NO_CODE_PARTIAL",
        "regex": r'(.*ORA-\d+:.*)',
        "mapping": {"Error Description": 1},
        "defaults": {"Code": "N/A", "IPN": "N/A", "SRKO": "N/A"}
    },
    {
        "name": "BASIC_PARTIAL",
        "regex": r'\b(\d{6})\b\s*;?[\s]*(.*)',
        "mapping": {"Code": 1, "Error Description": 2},
        "defaults": {"IPN": "N/A", "SRKO": "N/A"}
    }
]


def parse_cell(cell_value: Optional[str], source_row_num: int) -> pd.DataFrame:
    """
    Parses the content of a single cell to extract structured error records.

    This function serves as the main orchestrator for processing a cell's text.
    It handles various formats, including multi-line content and records
    concatenated in a single line. It uses smart logic to determine whether
    a semicolon is a record separator or part of a simple comment.

    Args:
        cell_value (Optional[str]): The text content from the source Excel cell.
        source_row_num (int): The original row number from the input Excel file.

    Returns:
        pd.DataFrame: A DataFrame containing the parsed records from the cell.
    """
    # This list will collect all records found in the cell.
    parsed_data: List[Dict[str, Any]] = []
    if pd.isna(cell_value):
        return pd.DataFrame(parsed_data)

    # A single cell can contain multiple lines, so we process each line individually.
    lines = re.split(r'\n', str(cell_value).strip())

    for line in lines:
        # First, normalize the line by collapsing multiple spaces and fixing common typos.
        line = re.sub(r'\s+', ' ', line.strip())
        line = line.replace('ОRA', 'ORA').replace('oRA', 'ORA')
        if not line:
            continue

        # --- Smart Semicolon Handling ---
        # We decide if a semicolon is a real separator or just part of the text.
        # It's a separator only if the line also contains an ORA error or a 6-digit code.
        has_semicolon = ';' in line
        has_ora_error = 'ORA-' in line
        has_6_digit_code = re.search(r'\b\d{6}\b', line) is not None

        if has_semicolon and (has_ora_error or has_6_digit_code):
            # This branch handles structured records that use semicolons as separators.
            if line.count('ORA-') > 1:
                # This handles the special case of multiple ORA errors on one line, separated by semicolons.
                multi_records = re.split(r';', line)
                for record_part in multi_records:
                    if record_part.strip():
                        logging.info(f"Processing multi-ORA fragment: {record_part.strip()}")
                        process_fragment(record_part.strip(), parsed_data)
                continue  # Skip the rest of the logic for this line.
            else:
                # This handles standard records like `<code>;<description>;<details>`.
                # It accumulates parts of a record until a new 6-digit code is found.
                fragments = re.split(r';', line)
                current_record = ''
                for fragment in fragments:
                    fragment = fragment.strip()
                    if not fragment: continue
                    if re.match(r'^\d{6}', fragment):
                        if current_record:
                            logging.info(f"Processing semicolon record: {current_record}")
                            process_fragment(current_record, parsed_data)
                        current_record = fragment
                    else:
                        current_record += f";{fragment}"
                if current_record:
                    logging.info(f"Processing semicolon record: {current_record}")
                    process_fragment(current_record, parsed_data)
        else:
            # This branch handles lines without special semicolons, or simple comments
            # that happen to contain a semicolon.
            # It splits the line if multiple 6-digit codes are found without semicolons.
            records = re.split(r'(?=\b\d{6}\s)', line)
            for record in records:
                if record.strip():
                    logging.info(f"Processing record: {record.strip()}")
                    process_fragment(record.strip(), parsed_data)

    # Finally, add the source row number to all records parsed from this one cell.
    for record in parsed_data:
        record[SOURCE_ROW_COLUMN] = source_row_num

    return pd.DataFrame(parsed_data)


def process_fragment(fragment: str, parsed_data: List[Dict[str, Any]]) -> None:
    """
    Processes a single text fragment by applying rules from PARSING_PATTERNS.

    Args:
        fragment (str): A string representing a potential single record.
        parsed_data (List[Dict[str, Any]]): A list where parsed records
                                           are collected (modified in-place).
    Returns:
        None
    """
    # Iterate through the predefined rules in the order they are listed.
    for rule in PARSING_PATTERNS:
        # Attempt to match the fragment against the rule's regex.
        match = re.match(rule["regex"], fragment, re.IGNORECASE)

        # If a match is found, process it and stop.
        if match:
            # Start building the result dictionary with the rule's default values.
            record = rule.get("defaults", {}).copy()
            # Populate the record from the captured regex groups based on the mapping.
            for key, group_index in rule["mapping"].items():
                record[key] = match.group(group_index).strip()
            # Apply any special transformations if defined for the rule.
            if "post_process" in rule:
                record = rule["post_process"](record)

            logging.info(f"Matched {rule['name']}: {record}")
            parsed_data.append(record)
            return  # Exit the function as soon as the first matching rule is found.

    # This fallback block executes only if no rules from the list were matched.
    logging.warning(f"No pattern matched. Using fallback for: '{fragment}'")
    parsed_data.append({
        "Code": "N/A",
        "Error Description": fragment,
        "IPN": "N/A",
        "SRKO": "N/A"
    })


def setup_logging() -> None:
    """
    Configures the logging system for the script.

    Sets up a logger that writes to both a file (overwritten on each run)
    and the console. Each log message is timestamped for easy tracking.
    """
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(LOG_FILE, mode='w', encoding='utf-8'),
            logging.StreamHandler()
        ]
    )


def main() -> None:
    """
    Main function to run the entire parsing process.
    """
    # Ensure output and log directories exist before starting.
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(LOG_DIR, exist_ok=True)

    # Initialize logging.
    setup_logging()
    logging.info("Script started.")

    # Safely read the Excel file with error handling for a missing file.
    try:
        input_data = pd.read_excel(INPUT_FILE, sheet_name=SHEET_NAME, engine="openpyxl")
    except FileNotFoundError:
        logging.error(f"Input file not found at '{INPUT_FILE}'. Make sure it's in the '{INPUT_DIR}' directory.")
        return

    # Clean up column names from extra spaces or characters.
    input_data.columns = input_data.columns.str.strip().str.replace('.', '', regex=False)

    # Pre-define the structure of the final DataFrame to ensure correct column order.
    output_columns = ["Code", "Error Description", "IPN", "SRKO", SOURCE_ROW_COLUMN]
    final_parsed_data = pd.DataFrame(columns=output_columns)

    # Check if at least one of the required source columns exists.
    if PRIMARY_COLUMN not in input_data.columns and FALLBACK_COLUMN not in input_data.columns:
        logging.error(f"Neither '{PRIMARY_COLUMN}' nor '{FALLBACK_COLUMN}' columns found in the input file!")
        return

    # Iterate through each row of the input DataFrame.
    for index, row in input_data.iterrows():
        source_row_num = index + 2
        logging.info(f"--- Parsing Excel row {source_row_num} ---")

        # 1. Get the raw values from the cells for the current row.
        raw_primary = row.get(PRIMARY_COLUMN)
        raw_fallback = row.get(FALLBACK_COLUMN)

        # 2. Convert values to strings only if they are not null/NaN.
        # This prevents empty pandas cells from becoming the literal string "nan".
        primary_value = str(raw_primary).strip() if pd.notna(raw_primary) and str(raw_primary).strip() else ""
        fallback_value = str(raw_fallback).strip() if pd.notna(raw_fallback) and str(raw_fallback).strip() else ""

        cell_to_parse: Optional[str] = None

        # 3. Determine if the value in the primary column is "insignificant".
        # An "insignificant" value is defined as a short number (less than 5 digits).
        is_primary_insignificant = primary_value.isdigit() and len(primary_value) < 5

        # 4. Decide which column to use for parsing based on the clean data.
        if is_primary_insignificant and fallback_value:
            # The main condition: if the primary value is insignificant and the fallback has data, choose the fallback.
            logging.info(f"Primary column contains insignificant value '{primary_value}'. Using data from '{FALLBACK_COLUMN}' column instead.")
            cell_to_parse = fallback_value
        elif primary_value:
            # Otherwise, if the primary column has any other data, use it.
            cell_to_parse = primary_value
        elif fallback_value:
            # If the primary column is empty, use the fallback.
            cell_to_parse = fallback_value

        # 5. If a cell was chosen for parsing, pass it to the processing function.
        if cell_to_parse:
            parsed_output = parse_cell(cell_to_parse, source_row_num)
            if not parsed_output.empty:
                final_parsed_data = pd.concat([final_parsed_data, parsed_output], ignore_index=True)
        else:
            logging.info("Both columns are empty. Skipping row.")

    # Re-apply column order to the final DataFrame as a safety measure.
    final_parsed_data = final_parsed_data.reindex(columns=output_columns)

    # Save the final result to a new Excel file.
    final_parsed_data.to_excel(OUTPUT_FILE, index=False, engine="openpyxl")
    logging.info(f"Parsing complete! Results saved to {OUTPUT_FILE}")
    logging.info(f"Detailed log saved to {LOG_FILE}")


if __name__ == "__main__":
    # Standard Python entry point to run the main function.
    main()