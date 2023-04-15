#!/bin/bash
 
python -m venv dev_env
dev_env\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
