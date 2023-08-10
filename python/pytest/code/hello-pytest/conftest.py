#!/usr/bin/env python3

import subprocess

import pytest
from py._xmlgen import html


# 自定义断言消息
def pytest_assertrepr_compare(op, left, right):
    if isinstance(left, str) and isinstance(right, str) and op == "==":
        return ["Comparing two strings:", "   vals: %s != %s" % (left, right)]


@pytest.fixture()
def custom_fixture():
    print("Custom fixture")


def pytest_html_report_title(report):
    report.title = "My very own title!"


def pytest_html_results_table_header(cells):
    cells.pop()
    cells.append(html.th("Author"))


def detect_authors_from_git_logs(filename):
    status, stdout = subprocess.getstatusoutput(
        f"git log --pretty=format:\"%ce\" {filename}"
    )
    authors = ["@" + i.split("@")[0] for i in stdout.split("\n")]
    author_times = {}
    for author in authors:
        if author not in author_times:
            author_times[author] = 1
        else:
            author_times[author] += 1
    authors = sorted(author_times.keys(), key=lambda x: author_times[x], reverse=True)
    return ' '.join(authors)


def pytest_html_results_table_row(report, cells):
    cells.pop()
    cells.append(html.td(detect_authors_from_git_logs(report.nodeid.split("::")[0])))
    # print(report.item.__dict__)


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    report = outcome.get_result()
