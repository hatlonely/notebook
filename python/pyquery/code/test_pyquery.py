import pytest
from pyquery import PyQuery as pq


@pytest.fixture(scope="session")
def d():
    return pq(filename="test.html")


def test_1(d):
    div = d(".document>.documentwrapper>.bodywrapper>.body>#pyquery-a-jquery-like-library-for-python")
    print(d(".document #pyquery-a-jquery-like-library-for-python p:first").text())


def test_2():
    d = pq("<html><body><a href='https://stackoverflow.com'>Next page</a><p>...Next time...</p></body></html>")
    d = d('a:Contains("Next")')
    assert d.text() == "Next page"
    assert d.attr['href'] == "https://stackoverflow.com"
