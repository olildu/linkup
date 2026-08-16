#!/bin/bash

# --- Configuration ---
# The absolute path to your project directory
PROJECT_DIR="/Users/ebinsanthosh/Documents/GitHub/Personal/linkup-backend"

# The absolute path to the python executable inside your virtual environment
# If your venv is in PROJECT_DIR/venv, this will be correct.
# To find it: `source venv/bin/activate` then `which python`
VENV_PYTHON_PATH="$PROJECT_DIR/venv/bin/python"

# The absolute path to the uvicorn executable inside your virtual environment
# To find it: `source venv/bin/activate` then `which uvicorn`
VENV_UVICORN_PATH="$PROJECT_DIR/venv/bin/uvicorn"

# The main application file and instance (e.g., main.py with an app instance named `app`)
APP_MODULE="app.main:app"

# --- Execution ---
echo "Starting FastAPI server..." >> /var/log/linkup-backend.log

# Navigate to the project directory
cd "$PROJECT_DIR"

# Execute uvicorn using the virtual environment's executable
# This command runs the server in the foreground, which is what launchd expects.
# All output will be redirected by launchd to the log files.
"$VENV_UVICORN_PATH" "$APP_MODULE" --host 0.0.0.0 --port 8002 --reload
