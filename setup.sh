#!/bin/bash
 
python3 -m venv dev_env
source dev_env/bin/activate

# 仮想環境に入っているかを確認
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Error: This script must be run within the virtual environment."
    exit 1
fi
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
