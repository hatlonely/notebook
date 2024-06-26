import socket
import subprocess
import time

import pytest


def is_port_open(host, port):
    """检查指定的端口是否开放"""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex((host, port)) == 0


@pytest.fixture(scope="session")
def setup():
    process = subprocess.Popen(
        ["flask", "--app", "main.py", "run"],
        cwd="../app",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    for _ in range(60):  # 尝试最多60秒
        if is_port_open('127.0.0.1', 5000):  # 假设 Flask 应用运行在5000端口
            break
        time.sleep(1)

    yield
    process.terminate()
    process.wait()
    stdout, stderr = process.communicate()
    print(stderr.decode(), stdout.decode())
