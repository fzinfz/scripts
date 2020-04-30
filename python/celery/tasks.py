from celery import Celery

# backend: optional, supports .get()
app = Celery('tasks', backend='amqp', broker='amqp://guest@localhost//')

import time

@app.task
def add(x, y, sleep_time=1):
    print(f"sleep {sleep_time}s") # no output with delay(), use logging instead
    time.sleep(sleep_time)
    return x + y

@app.task
def get_type(obj):
    return str(type(obj))

@app.task
def return_same(obj):
    return obj