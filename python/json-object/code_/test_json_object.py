from .json_object import json_object


@json_object
class A:
    key1: int
    key2: str

    @json_object
    class B:
        key3: str

        @json_object
        class C:
            key4: str

        c: C
        cs: list[C]

    b: B
    bs: list[B]
    ds: dict[str, B]


def test_json_object_from_dict():
    a = A(
        {
            "key1": "1",
            "key2": "val2",
            "b": {"key3": "val3", "c": {"key4": "val4"}, "cs": [{"key4": "val4"}]},
            "bs": [{"key3": "val3", "c": {"key4": "val4"}, "cs": [{"key4": "val4"}]}],
            "ds": {"key5": {"key3": "val6"}},
        }
    )
    print(a)
    assert a.key1 == 1
    assert a.key2 == "val2"
    assert a.b.cs[0].key4 == "val4"
    assert a.bs[0].cs[0].key4 == "val4"
    assert a.ds["key5"].key3 == "val6"


def test_json_object_from_json():
    a = A(
        """{
        "key1": 1,
        "key2": "val2",
        "b": {
            "key3": "val3",
            "c": {
                "key4": "val4"
            },
            "cs": [{
                "key4": "val4"
            }]
        },
        "bs": [{
            "key3": "val3",
            "c": {
                "key4": "val4"
            },
            "cs": [{
                "key4": "val4"
            }]
        }]
    }"""
    )
    print(a)
    assert a.key1 == 1
    assert a.key2 == "val2"
    assert a.b.cs[0].key4 == "val4"
    assert a.bs[0].cs[0].key4 == "val4"


def test_json_object_from_yaml():
    a = A(
        """
b:
  c:
    key4: val4
  cs:
  - key4: val4
  key3: val3
bs:
- c:
    key4: val4
  cs:
  - key4: val4
  key3: val3
key1: '1'
key2: val2
""",
        type_="yaml",
    )
    print(a)
    assert a.key1 == 1
    assert a.key2 == "val2"
    assert a.b.cs[0].key4 == "val4"
    assert a.bs[0].cs[0].key4 == "val4"
