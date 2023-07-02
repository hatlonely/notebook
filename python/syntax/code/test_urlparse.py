from urllib.parse import urlparse


def test_urlparse_ok():
    info = urlparse("https://hatlonely:123456@docs.python.org:80/zh-cn/3/library/urllib.parse.html?key=val#url-parsing")
    assert info.scheme == "https"
    assert info.hostname == "docs.python.org"
    assert info.port == 80
    assert info.path == "/zh-cn/3/library/urllib.parse.html"
    assert info.username == "hatlonely"
    assert info.password == "123456"
    assert info.netloc == "hatlonely:123456@docs.python.org:80"
    assert info.fragment == "url-parsing"
    assert info.query == "key=val"


def test_urlparse_no_scheme():
    info = urlparse("docs.python.org")
    assert info.scheme == ""
    assert info.hostname is None
    assert info.path == "docs.python.org"
