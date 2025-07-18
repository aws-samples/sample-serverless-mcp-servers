import logging
import os

log_format = '%(asctime)s %(levelname)s %(filename)s:%(lineno)d :: %(message)s'

def get():
    l = logging.getLogger()
    l.setLevel(logging.INFO)

    if os.getenv("AWS_LAMBDA_FUNCTION_NAME"):
        for handler in l.handlers:
            handler.setFormatter(logging.Formatter(log_format))
    else:
        handler = logging.StreamHandler()
        handler.setFormatter(logging.Formatter(log_format))
        l.addHandler(handler)

    return l
