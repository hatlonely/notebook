import threading
import time


def test_threading():
    def my_func(arg1, arg2):
        print(arg1, arg2)

    t1 = threading.Thread(target=print, args=("Hello",))
    t2 = threading.Thread(target=my_func, args=("arg1", 2))
    t1.start()
    t2.start()
    t1.join()
    t2.join()
