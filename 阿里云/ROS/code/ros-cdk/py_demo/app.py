#!/usr/bin/env python3

import ros_cdk_core as core

from py_demo.py_demo_stack import PyDemoStack


app = core.App()

PyDemoStack(app, "py-demo")

app.synth()
