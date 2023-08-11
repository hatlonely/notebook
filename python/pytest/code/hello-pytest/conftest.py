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


def detect_authors_from_git_blame(file, func):
    if func:
        status, stdout = subprocess.getstatusoutput(
            f"git --no-pager blame -c -e -L :{func} {file}"
        )
    else:
        status, stdout = subprocess.getstatusoutput(
            f"git --no-pager blame -c -e {file}"
        )
    for line in stdout.split("\n"):
        line = line.split("\t")[1].split("@")[0][2:]
    authors = ["@" + i.split("\t")[1].split("@")[0][2:] for i in stdout.split("\n")]
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
    file, _, func = report.location
    func = func.split("[")[0]
    func = func.split(".")[0]
    cells.append(html.td(detect_authors_from_git_blame(file, func)))


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    report = outcome.get_result()
