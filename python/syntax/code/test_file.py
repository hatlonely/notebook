import os


def test_list_directory():
    for i in os.listdir(".."):
        if os.path.isdir(i):
            print(f"{i} is directory")
        else:
            print(f"{i} is file")


def test_walk():
    for root, dirs, files in os.walk("../"):
        for i in ([os.path.join(root, f) for f in files]):
            print(i)
        for i in ([os.path.join(root, d) for d in dirs]):
            print(i)
