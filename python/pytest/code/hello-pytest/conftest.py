#!/usr/bin/env python3

import subprocess

import py.xml
import pytest


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
    cells.append(py.xml.html.th("Author"))


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


# 从文件的 git blame 中获取作者信息，并按照代码行数排序
def detect_authors_from_git_blame(file, func):
    if func:  # doctest 场景
        status, stdout = subprocess.getstatusoutput(
            f"git --no-pager blame -c -e -L :{func} {file}"
        )
    else:
        status, stdout = subprocess.getstatusoutput(
            f"git --no-pager blame -c -e {file}"
        )
    authors = ["@" + i.split("\t")[1].split("@")[0][2:] for i in stdout.split("\n")]
    author_times = {}
    for author in authors:
        if author not in author_times:
            author_times[author] = 1
        else:
            author_times[author] += 1
    authors = sorted(author_times.keys(), key=lambda x: author_times[x], reverse=True)
    # 取 commit 次数最多的 3 位同学
    if len(authors) > 3:
        authors = authors[:3]
    return ' '.join(authors)


def pytest_html_results_table_row(report, cells):
    cells.pop()
    file, _, func = report.location
    func = func.split("[")[0]  # pytest.mark.parameterize，参数在中括号中
    func = func.split(".")[0]  # 测试类，只取类名
    cells.append(py._xmlgen.html.td(detect_authors_from_git_blame(file, func)))


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    report = outcome.get_result()


# pytest 命令行参数支持
#   --no-skips: 不要跳过测试
def pytest_addoption(parser):
    parser.addoption(
        "--no-skips",
        action="store_true",
        default=False, help="disable skip marks"
    )


enable_skip = True


@pytest.hookimpl(tryfirst=True)
def pytest_cmdline_preparse(config, args):
    if "--no-skips" in args:
        global enable_skip
        enable_skip = False
