# --- STAGE 1: Builder/Tester ---
# This stage installs all dependencies (including tests), runs the tests,
# and prepares the application for the final stage.
FROM python:3.12-slim as builder

WORKDIR /app

# MODIFIED: Path now points to the correct package
COPY packages/deported_children_parser/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# MODIFIED: Path now points to the correct package
COPY packages/deported_children_parser/ .

# Run the tests. If tests fail, the Docker build will stop here.
RUN pytest


# --- STAGE 2: Final Production Image ---
# This stage creates the final, clean image for running the application.
# It does NOT include test files or test libraries.
FROM python:3.12-slim

WORKDIR /app

# Copy only the necessary production dependencies from the builder stage
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy only the application script from the builder stage
COPY --from=builder /app/parser.py .

# Define the command to run your script when the container starts.
CMD ["python", "parser.py"]