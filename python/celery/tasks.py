from celery import Celery

app = Celery('tasks', backend='amqp', broker='amqp://guest@localhost//') # backend: optional

import time

@app.task
def add(x, y, sleep_time=1):
    print(f"sleep {sleep_time}s") # no output, use logging instead
    time.sleep(sleep_time)
    return x + y

