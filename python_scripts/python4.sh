#!/bin/bash
python3 --version
virtualenv -p python3 venv
source venv/bin/activate
pip install pynput

python3 mouselogger.py