import sys
import os
import pandas as pd

# Add the project root directory to the Python path to allow imports from parser.py
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from parser import process_fragment

def test_full_match_with_code():
    """Tests a standard record with a 6-digit code, ORA error, IPN, and SRKO."""
    fragment = "422743 Некоректні вхідні данні ORA-20000: ІПН [3539601588] знайдено в СРКО [135115950]"
    parsed_data = []
    process_fragment(fragment, parsed_data)

    assert len(parsed_data) == 1
    result = parsed_data[0]
    assert result["Code"] == "422743"
    assert "ORA-20000" in result["Error Description"]
    assert result["IPN"] == "3539601588"
    assert result["SRKO"] == "135115950"

def test_no_code_full_match():
    """Tests a record without a leading code but with ORA, IPN, and SRKO."""
    fragment = "Некоректні вхідні данні ORA-20000: ІПН [4474904001] знайдено в СРКО [134433155]"
    parsed_data = []
    process_fragment(fragment, parsed_data)

    assert len(parsed_data) == 1
    result = parsed_data[0]
    assert result["Code"] == "N/A"
    assert result["Error Description"] == "Некоректні вхідні данні ORA-20000"
    assert result["IPN"] == "4474904001"
    assert result["SRKO"] == "134433155"

def test_fallback_for_plain_comment():
    """Tests that a plain text comment without any special markers uses the fallback rule."""
    fragment = "всі справи замігровано, помилок нема"
    parsed_data = []
    process_fragment(fragment, parsed_data)

    assert len(parsed_data) == 1
    result = parsed_data[0]
    assert result["Code"] == "N/A"
    assert result["Error Description"] == fragment

def test_date_string_is_not_a_code():
    """
    Regression test: Ensures a string starting with a date (e.g., "01.07.2025")
    is not mistaken for a record with a code "01".
    """
    fragment = "01.07.2025 міграції з вузлів не розпочато."
    parsed_data = []
    process_fragment(fragment, parsed_data)

    assert len(parsed_data) == 1
    result = parsed_data[0]
    assert result["Code"] == "N/A"
    assert result["Error Description"] == fragment