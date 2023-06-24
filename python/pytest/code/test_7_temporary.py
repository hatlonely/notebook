#!/usr/bin/env python3

def test_tmp_path(tmp_path):
    p = tmp_path / "1.txt"
    p.write_text("Hello World")

    print(p)
    assert p.read_text() == "Hello World"


def test_tmp_path_factory(tmp_path_factory):
    p = tmp_path_factory.mktemp("mydir") / "1.txt"
    p.write_text("Hello World")

    print(p)
    assert p.read_text() == "Hello World"
