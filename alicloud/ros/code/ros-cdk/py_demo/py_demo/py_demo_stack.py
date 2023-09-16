import ros_cdk_core as core
import ros_cdk_ecs as ecs

class PyDemoStack(core.Stack):
    def __init__(self, scope: core.Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        vpc = ecs.Vpc(self, "vpc", ecs.VPCProps(
            cidr_block="10.0.0.0/24",
            description="create by ros-cdk",
            vpc_name="test-ros-cdk-vpc",
        ))
