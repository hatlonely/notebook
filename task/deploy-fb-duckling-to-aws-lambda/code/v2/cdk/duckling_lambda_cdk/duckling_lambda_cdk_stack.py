from aws_cdk import Stack
from constructs import Construct
import aws_cdk.aws_iam as iam
import aws_cdk.aws_ecr as ecr
import aws_cdk.aws_lambda as lambda_


class DucklingLambdaCdkStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        duckling_role = iam.Role(
            self, "duckling_role",
            assumed_by=iam.ServicePrincipal("lambda.amazonaws.com"),

        )
        duckling = lambda_.Function(
            self, "duckling",
            function_name="duckling",
            role=duckling_role,
            code=lambda_.Code.from_ecr_image(
                repository=ecr.Repository.from_repository_name(self, "repo", repository_name="duckling-for-lambda"),
                tag="1.0.0",
            ),
            runtime=lambda_.Runtime.FROM_IMAGE,
            handler=lambda_.Handler.FROM_IMAGE,
        )
        duckling_url = lambda_.FunctionUrl(
            self, "duckling_url",
            function=duckling,
            auth_type=lambda_.FunctionUrlAuthType.NONE,
        )
