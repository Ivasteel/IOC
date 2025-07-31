# Deported Children Data Parser

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-ivasteel%2Fdeported--children--parser-blue)](https://hub.docker.com/r/ivasteel/deported-children-parser)

This project provides a Python script to automate the parsing and structuring of data related to deported children. It reads lists of names and dates of birth from an Excel file, handles numerous complex formats and variations, and outputs a clean, structured dataset.

The application is containerized using Docker for easy setup and execution in any environment, and includes an automated test suite to ensure reliability.

---

## 📖 Table of Contents

-   [✨ Features](#-features)
-   [📂 Project Structure](#-project-structure)
-   [🧪 Testing](#-testing)
-   [🚀 How to Use (For End-Users)](#-how-to-use-for-end-users)
-   [👨‍💻 How to Use (For Developers)](#-how-to-use-for-developers)
-   [✍️ Author](#️-author)
-   [📜 License](#-license)

---

## ✨ Features

-   **Complex Name Parsing**: Intelligently handles multiple name variations within a single cell, including alternatives in parentheses `()` and separated by slashes `/`.
-   **One-to-Many Record Generation**: Creates multiple structured output rows from a single input row that contains data variations.
-   **Advanced Date Parsing**: Processes various date formats, including multiple dates in one cell, year-only alternatives (`2010 або 21.06.2006`), and incomplete dates (`.07.2017`).
-   **Data Quality Status**: Adds a `Status` column (`Successful`, `To Verify`) to automatically flag records that may require manual review.
-   **Data Traceability**: Adds `Source Row Number` and `Source Data` columns to the output, linking each parsed record to its original data.
-   **Dockerized Environment**: Fully containerized with a multi-stage `Dockerfile` for easy setup, testing, and execution.
-   **Automated Testing**: Includes a `pytest` suite with unit and functional tests.

---

## 📂 Project Structure

```
.                        # The root of the deported_children_parser package
├── input/               # Directory for input data
│   └── Book.xlsx        # The source Excel file should be placed here
├── output/              # Directory where parsed results will be saved
├── log/                 # Directory where log files will be saved
├── tests/               # Contains all automated tests for the project
│   ├── unit/            # Unit tests for individual functions
│   └── functional/      # Functional tests for component interactions
├── parser.py            # The main application script
├── Dockerfile           # Instructions for building the Docker image
└── requirements.txt     # List of Python dependencies
```

---

## 🧪 Testing

To run the automated tests for this parser:

1.  Navigate to the package directory:
    ```bash
    cd packages/deported_children_parser
    ```
2.  Install dependencies and run tests:
    ```bash
    pip install -r requirements.txt
    pytest
    ```

---

## 🚀 How to Use (For End-Users)

These instructions are for running the pre-built Docker image from Docker Hub. No source code or Python installation is required.

**Prerequisites:** [Docker](https://www.docker.com/get-started) must be installed.

#### Step 1: Create a Workspace
On your computer, create a main folder for your work (e.g., `C:\parser_run`). Inside it, create three subfolders: `input`, `output`, and `log`.

#### Step 2: Add Your Input File
Place your Excel file (it must be named **`Book.xlsx`**) into the `input` folder you just created.

#### Step 3: Run the Parser
1.  Open your terminal and navigate to the main workspace folder you created (e.g., `cd C:\parser_run`).
2.  Execute the command below. Docker will automatically download the image and run the script.

    **Note:** You may first need to create a public repository named `deported-children-parser` on your Docker Hub account (`ivasteel`).

    ```bash
    docker run --rm \
      -v "$(pwd)/input:/app/input" \
      -v "$(pwd)/output:/app/output" \
      -v "$(pwd)/log:/app/log" \
      ivasteel/deported-children-parser
    ```
    *(For Windows Command Prompt, use `%cd%` instead of `$(pwd)`)*

#### Step 4: Check the Result
The parsed file `Parsed_Output.xlsx` will appear in your `output` folder.

---

## 👨‍💻 How to Use (For Developers)

These instructions are for developers who have cloned the repository. All commands should be run from the **root directory of the `IOC` repository**.

#### Step 1: Clone the Repository
```bash
git clone [https://github.com/ivasteel/IOC.git](https://github.com/ivasteel/IOC.git)
cd IOC
```

#### Step 2: Build the Docker Image
This command builds the image for this specific parser and tags it.
```bash
docker build -t deported-children-parser -f packages/deported_children_parser/Dockerfile .
```

#### Step 3: Run the Container
This command runs the locally built image, mapping the correct project folders.
```bash
docker run --rm \
  -v "$(pwd)/packages/deported_children_parser/input:/app/input" \
  -v "$(pwd)/packages/deported_children_parser/output:/app/output" \
  -v "$(pwd)/packages/deported_children_parser/log:/app/log" \
  deported-children-parser
```
---

## ✍️ Author

**Vasyl Ivchyk**
* Lead Data Engineer & AI Enthusiast
* 💼 LinkedIn: [Vasyl Ivchyk](https://www.linkedin.com/in/vasyl-ivchyk-1a0b1358/)
* 📧 Email: ivasteel@gmail.com

---

## 📜 License

This project is **MIT Licensed**.