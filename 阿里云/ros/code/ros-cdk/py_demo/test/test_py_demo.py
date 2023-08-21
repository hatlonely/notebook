#!/usr/bin/env python3
import unittest
import ros_cdk_core as core
from py_demo.py_demo_stack import PyDemoStack


class TestStack(unittest.TestCase):
    def setUp(self):
        pass

    def test_stack(self):
        app = core.App()
        stack = PyDemoStack(app, "testpy-demo")
        artifact = app.synth().get_stack_artifact(stack.artifact_id).template
        expect = {
                   "Metadata": {
                     "ALIYUN::ROS::Interface": {
                       "TemplateTags": [
                         "Create by ROS CDK"
                       ]
                     }
                   },
                   "ROSTemplateFormatVersion": "2015-09-01"
                 }
        self.assertDictContainsSubset(artifact, expect)

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()