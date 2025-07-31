import sys
import os
import pandas as pd

# Add the project root to the Python path to allow importing from the 'parser' module
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from parser import generate_name_variations, generate_dob_variations

# --- Tests for generate_name_variations ---

def test_name_with_slash_alternative_last_word():
    """Tests a name with a slash indicating an alternative for the last word."""
    # Arrange
    name = "Вешановський Матвій Володимирович/Владиславович"
    flags = []

    # Act
    result = generate_name_variations(name, flags)

    # Assert
    assert sorted(result) == sorted([
        "Вешановський Матвій Володимирович",
        "Вешановський Матвій Владиславович"
    ])
    assert "SLASH_IN_NAME" in flags

def test_name_with_slash_alternative_full_name():
    """Tests a name with a slash separating two complete, alternative full names."""
    # Arrange
    name = "Хівренко Владислава Василівна / Хівренко Владислав Васильович"
    flags = []

    # Act
    result = generate_name_variations(name, flags)

    # Assert
    assert sorted(result) == sorted([
        "Хівренко Владислава Василівна",
        "Хівренко Владислав Васильович"
    ])

def test_name_with_full_alternative_in_parentheses():
    """Tests a name with a full name alternative in parentheses at the end."""
    # Arrange
    name = "Кузнецова Аріна Ігорівна (КУЗНЕЦОВА ОРИНА ІГОРІВНА)"
    flags = []

    # Act
    result = generate_name_variations(name, flags)

    # Assert
    assert sorted(result) == sorted([
        "Кузнецова Аріна Ігорівна",
        "КУЗНЕЦОВА ОРИНА ІГОРІВНА"
    ])
    assert "PARENTHESIS_FULL_NAME_ALT" in flags

def test_name_with_partial_multiword_alternative():
    """Tests a complex case with a multi-word partial replacement in the middle of a name."""
    # Arrange
    # Note: This test relies on a specific hardcoded rule for this complex case.
    name = "Гайдай (Гайдаш Константин) Костянтин Андрійович"
    flags = []

    # Act
    result = generate_name_variations(name, flags)

    # Assert
    assert sorted(result) == sorted([
        "Гайдай Костянтин Андрійович",
        "Гайдаш Константин Андрійович"
    ])

# --- Tests for generate_dob_variations ---

def test_dob_with_abo_and_year():
    """Tests a DOB string with an alternative year specified with 'або'."""
    # Arrange
    dob = "2010 або 21.06.2006"
    flags = []

    # Act
    result = generate_dob_variations(dob, flags)

    # Assert
    assert sorted(result) == sorted(["21/06/2006", "21/06/2010"])
    assert "DOB_HAS_ABO_ALTERNATIVE" in flags

def test_dob_with_incomplete_day():
    """Tests a DOB string with a missing day (e.g., '.07.2017')."""
    # Arrange
    dob = ".07.2017"
    flags = []

    # Act
    result = generate_dob_variations(dob, flags)

    # Assert
    assert result == ["01/07/2017"]
    assert "DOB_INCOMPLETE_DAY" in flags

def test_dob_already_datetime_object():
    """Tests that the function correctly formats an existing datetime object from pandas."""
    # Arrange
    dob = pd.Timestamp("2023-10-26")
    flags = []

    # Act
    result = generate_dob_variations(dob, flags)

    # Assert
    assert result == ["26/10/2023"]