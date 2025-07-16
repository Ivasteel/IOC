# --- STAGE 1: Builder/Tester ---
FROM python:3.12-slim as builder

WORKDIR /app

# Install pytest and other dependencies
COPY packages/mohu_error_parser/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all project files and tests
COPY packages/mohu_error_parser/ .

# Run the tests
RUN pytest


# --- STAGE 2: Final Production Image ---
FROM python:3.12-slim

WORKDIR /app

# Copy only the necessary production dependencies from the builder stage
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy only the application script from the builder stage
COPY --from=builder /app/parser.py .

# Define the command to run your script when the container starts.
CMD ["python", "parser.py"]