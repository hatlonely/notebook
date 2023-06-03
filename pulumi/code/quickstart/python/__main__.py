import pulumi
import pulumi_alicloud as alicloud

az = "cn-beijing-a"

vpc = alicloud.vpc.Network(
    "my-vpc",
    cidr_block="172.16.0.0/12",
)

vswitch = alicloud.vpc.Switch(
    "pulumi_vswitch",
    zone_id=az,
    cidr_block="172.16.0.0/21",
    vpc_id=vpc.id,
)

sg = alicloud.ecs.SecurityGroup(
    "pulumi_sg",
    description="pulumi security_groups",
    vpc_id=vpc.id,
)

sg_rule= alicloud.ecs.SecurityGroupRule(
    "sg_rule",
    security_group_id=sg.id,
    ip_protocol="tcp",
    type="ingress",
    nic_type="intranet",
    port_range="22/22",
    cidr_ip="0.0.0.0/0"
)

instance=alicloud.ecs.Instance(
    "ecs-instance2",
    availability_zone=az,
    instance_type="ecs.t6-c1m1.large",
    security_groups =[sg.id],
    image_id="ubuntu_18_04_64_20G_alibase_20190624.vhd",
    instance_name ="ecsCreatedByPulumi2",
    vswitch_id=vswitch.id,
    internet_max_bandwidth_out=0,
)
