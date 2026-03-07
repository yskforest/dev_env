#!/bin/bash
set -eu

VENV_DIR="dev_env"

if ! python3 -c "import sys; assert sys.version_info >= (3, 8)" &>/dev/null; then
    echo "Error: Python 3.8 or higher is required." >&2
    exit 1
fi

if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment in '$VENV_DIR'..."
  python3 -m venv "$VENV_DIR"
fi

echo "Activating virtual environment and installing dependencies..."
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip
pip install -r requirements.txt

echo "Setup complete. To activate the environment, run: source $VENV_DIR/bin/activate"