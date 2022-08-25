from pynput import mouse
import logging
import pynput
import os
import time

print(os.environ)

cwd = os.getcwd()
log_directory = os.path.join(cwd,"Key_logs")
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

mouse_logger = setup_logger('mouse_logger', 'mouse_log0.txt')

def get_mouse_event():
    with mouse.Events() as events:
        event = events.get(1.0)
        if event is not None:
            mouse_logger.info('Received event {}'.format(event))

while True:
    get_mouse_event()
    time.sleep(1)
