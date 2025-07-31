import pandas as pd
import sys
import os

# Add the project root to the Python path to allow importing from the 'parser' module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from parser import process_row_combinations

def test_combination_of_name_and_dob_alternatives():
    """
    Tests the Cartesian product: 2 name variations and 2 date variations
    should result in 4 total records.
    """
    # Arrange: Create a mock row with 2 name and 2 date alternatives.
    row_data = {
        'ПІБ': 'Глухов Марк (Марко) Анатолійович',
        'Дата народження': '10.03.2005 або 03.10.2005'
    }
    row = pd.Series(row_data)

    # Act: Process the row using the main combination function.
    result_records = process_row_combinations(row, source_row_num=100)

    # Assert: Check that 4 records were generated (2 names * 2 dates).
    assert len(result_records) == 4

    # Assert: Verify that the correct sets of names and DOBs were produced.
    # Using sets allows for order-independent comparison.
    full_names_result = {rec['Full Name'] for rec in result_records}
    dobs_result = {rec['DOB'] for rec in result_records}
    expected_names = {"Глухов Марк Анатолійович", "Глухов Марко Анатолійович"}
    expected_dobs = {"10/03/2005", "03/10/2005"}

    assert full_names_result == expected_names
    assert dobs_result == expected_dobs
    # Assert: Check that the status is correctly marked as 'To Verify' due to the alternatives.
    assert all(rec['Status'] == 'To Verify' for rec in result_records)

def test_single_name_and_single_dob():
    """Tests that a standard row with no variations is processed correctly."""
    # Arrange: Create a mock row with a simple, unambiguous name and DOB.
    row_data = {
        'ПІБ': 'Абазіна Ганна Олександрівна',
        'Дата народження': '19/7/2007' # Using DD/MM/YYYY format
    }
    row = pd.Series(row_data)

    # Act: Process the row.
    result_records = process_row_combinations(row, source_row_num=2)

    # Assert: Check that exactly one record was generated.
    assert len(result_records) == 1
    record = result_records[0]

    # Assert: Verify the content of the single record.
    assert record['Full Name'] == 'Абазіна Ганна Олександрівна'
    assert record['DOB'] == '19/07/2007'
    assert record['Surname'] == 'Абазіна'
    assert record['Status'] == 'Successful'