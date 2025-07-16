import sys
import os
import pandas as pd

# Add the project root directory to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from parser import parse_cell

def test_parse_cell_with_multiple_lines():
    """
    Functional test for parse_cell.
    Checks if it correctly processes a multi-line string containing various record types.
    """
    # A single cell value with three different lines
    cell_content = (
        "458393 Некоректні вхідні данні ORA-20000: ІПН [3897108824] знайдено в СРКО [126201875]\n"
        "ORA-01403: no data found\n"
        "Простий коментар без помилок"
    )

    # Run the parsing function
    result_df = parse_cell(cell_content, source_row_num=10) # Using a dummy row number

    # Assertions
    assert isinstance(result_df, pd.DataFrame)
    assert len(result_df) == 3 # Should produce three records

    # Check the first record (FULL match)
    assert result_df.iloc[0]["Code"] == "458393"
    assert result_df.iloc[0]["IPN"] == "3897108824"

    # Check the second record (NO_CODE_PARTIAL match)
    assert result_df.iloc[1]["Code"] == "N/A"
    assert "ORA-01403" in result_df.iloc[1]["Error Description"]

    # Check the third record (Fallback)
    assert result_df.iloc[2]["Code"] == "N/A"
    assert result_df.iloc[2]["Error Description"] == "Простий коментар без помилок"

    # Check that the source row number was correctly applied to all records
    assert all(result_df["Source Row"] == 10)