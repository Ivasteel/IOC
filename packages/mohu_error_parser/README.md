# MOHU Error Parser

This project provides a Python script to automate the parsing and structuring of error reports from exchanges with the Ministry of Health of Ukraine (MOHU).

The application is containerized using Docker for easy setup and execution in any environment, and includes an automated test suite to ensure reliability.

---

## 📖 Table of Contents

-   [✨ Features](#-features-mohu-error-parser)
-   [📂 Project Structure](#-project-structure)
-   [🚀 How to Use (For End Users)](#-how-to-use-for-end-users)
-   [🚀 How to Use (For Developers)](#-how-to-use-for-developers)
-   [✍️ Author](#-author)
-   [📜 License](#-license)

---

## ✨ Features

-   **Advanced Text Parsing**: Processes complex text formats using a centralized list of regex rules.
-   **Dual Column Logic**: Prioritizes the `Помилки` column and uses `Коментарі` as a fallback.
-   **Data Traceability**: Adds a `Source Row` column to the output, linking each parsed record to its original line in the input file.
-   **Robust Logging**: Generates a detailed `parsing_log.txt` file for each run while also displaying progress in the console.
-   **Automated Testing**: Includes a `pytest` suite with unit and functional tests to ensure code reliability.
-   **Dockerized Environment**: Fully containerized with a multi-stage `Dockerfile` for easy setup, testing, and execution.

---

## 📂 Project Structure
```
.                        # The root of the mohu_error_parser package
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
└── README.md            # The main project documentation
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

    **Note:** Replace `your-dockerhub-username` with your actual Docker Hub login.
    ```bash
    docker run --rm \
      -v "$(pwd)/input:/app/input" \
      -v "$(pwd)/output:/app/output" \
      -v "$(pwd)/log:/app/log" \
      your-dockerhub-username/mohu-error-parser
    ```
    *(For Windows Command Prompt, use `%cd%` instead of `$(pwd)`)*

#### Step 4: Check the Result
The parsed file `Parsed_Output.xlsx` will appear in your `output` folder.

---

## 👨‍💻 How to Use (For Developers)

These instructions are for developers who have cloned the repository and want to build the image and run tests locally. All commands should be run from the **root directory of the `IOC` repository**.

#### Step 1: Clone the Repository
```bash
git clone [https://github.com/your-username/IOC.git](https://github.com/your-username/IOC.git)
cd IOC
```

#### Step 2: Build the Docker Image
This command will build the image, run the automated tests inside the container, and tag the image as `mohu-error-parser`.
```bash
docker build -t mohu-error-parser -f packages/mohu_error_parser/Dockerfile .
```

#### Step 3: Run the Container
This command runs the locally built image and maps the correct project folders.
```bash
docker run --rm \
  -v "$(pwd)/packages/mohu_error_parser/input:/app/input" \
  -v "$(pwd)/packages/mohu_error_parser/output:/app/output" \
  -v "$(pwd)/packages/mohu_error_parser/log:/app/log" \
  mohu-error-parser
```

#### Step 4: Run Tests Locally (Optional)
If you want to run tests without Docker:
```bash
cd packages/mohu_error_parser
pip install -r requirements.txt
pytest
```
---

## ✍️ Author

**Your Name**
* Vasyl Ivchyk – Lead Data Engineer & AI Enthusiast
* 💼 LinkedIn: [Vasyl Ivchyk](https://www.linkedin.com/in/vasyl-ivchyk-1a0b1358/)
* 📧 Email: [ivasteel@gmail.com]()

---

## 📜 License

This project is **MIT Licensed** – feel free to use and modify it! :)