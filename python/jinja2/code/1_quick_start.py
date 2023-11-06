import jinja2

tpl = """
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }}</title>
</head>
<body>
    <h1>Hello, {{ name }}!</h1>
    <p>Today is {{ date }}.</p>
</body>
</html>
"""

env = jinja2.Environment()
template = env.from_string(tpl)
out = template.render(title="Hello", name="World", date="2016-01-01")
print(out)
