import pytest

import envs


@pytest.fixture(scope="session")
def environment():
    return envs.Environment("env.yaml")
