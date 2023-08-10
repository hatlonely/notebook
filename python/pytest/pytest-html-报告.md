# pytest html 报告

pytest 安装 pytest-html 插件后可以支持 html 报告

## 安装

```shell
pip install pytest-html
```

## 执行测试

```shell
pytest --html=report.html
```

## 修改报告标题

在 conftest.py 中添加

```python
def pytest_html_report_title(report):
    report.title = "My very own title!"
```

## 修改报告表格内容

去掉最后一列 links，增加一列作者，方便找到对应的开发同学

```python
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
```

## 参考链接

- [pytest html 官网文档](https://pytest-html.readthedocs.io/en/latest/)
