from aws_cdk import (
    Stack,
)
from constructs import Construct

class HelloWorldStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # example resource
        # queue = sqs.Queue(
        #     self, "HelloWorldQueue",
        #     visibility_timeout=Duration.seconds(300),
        # )
