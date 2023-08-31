import json


def test_json1():
    class A():
        key1: int
        key2: str

        def __init__(self, d):
            self.key1 = d.get("key1")
            self.key2 = d.get("key2")

    a = A(json.loads("""{"key1":1,"key2": "val2"}"""))
    assert json.dumps(vars(a)) == """{"key1": 1, "key2": "val2"}"""


def test_json2():
    class A():
        key1: int
        key2: str

        def __init__(self, d):
            for k, v in d.items():
                setattr(self, k, v)

    a = A(json.loads("""{"key1":1,"key2": "val2"}"""))
    assert json.dumps(vars(a)) == """{"key1": 1, "key2": "val2"}"""
