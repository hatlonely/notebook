package main

import (
	"github.com/pulumi/pulumi-alicloud/sdk/v2/go/alicloud/vpc"
	"github.com/pulumi/pulumi-alicloud/sdk/v2/go/alicloud/ecs"
	"github.com/pulumi/pulumi/sdk/v2/go/pulumi"
)

// 不推荐使用 golang 编写
// 1. 类型转换太繁琐
// 2. 修改需要重新编译

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		zone_id := "cn-beijing-b"

		vpc_, err := vpc.NewNetwork(ctx, "my-vpc", &vpc.NetworkArgs{
			CidrBlock: pulumi.StringPtr("172.16.0.0/12"),
		})
		if err != nil {
			return err
		}

		vswitch, err := vpc.NewSwitch(ctx, "pulumi_vswitch", &vpc.SwitchArgs{
			ZoneId: pulumi.String(zone_id),
			CidrBlock: pulumi.String("172.16.0.0/21"),
			VpcId: vpc_.ID(),
		})
		if err != nil {
			return err
		}

		sg, err := ecs.NewSecurityGroup(ctx, "pulumi_sg", &ecs.SecurityGroupArgs{
			Description: pulumi.StringPtr("pulumi security_groups"),
			VpcId: vpc_.ID(),
		})
		if err != nil {
			return err
		}
		_, err = ecs.NewSecurityGroupRule(ctx, "sg_rule", &ecs.SecurityGroupRuleArgs{
			SecurityGroupId: sg.ID(),
			IpProtocol: pulumi.String("tcp"),
			Type: pulumi.String("ingress"),
			NicType: pulumi.StringPtr("intranet"),
			PortRange: pulumi.StringPtr("22/22"),
			CidrIp: pulumi.StringPtr("0.0.0.0/0"),
		})
		if err != nil {
			return err
		}

		instance, err := ecs.NewInstance(ctx, "ecs-instance-by-pulumi", &ecs.InstanceArgs{
			AvailabilityZone: pulumi.StringPtr(zone_id),
			InstanceType: pulumi.String("ecs.t6-c1m1.large"),
			SecurityGroups: pulumi.ToStringArrayOutput([]pulumi.StringOutput{sg.ID().ToStringOutput()}),
			ImageId: pulumi.String("ubuntu_18_04_64_20G_alibase_20190624.vhd"),
			InstanceName: pulumi.String("ecsCreatedByPulumi2"),
			VswitchId: vswitch.ID(),
			InternetMaxBandwidthOut: pulumi.Int(0),
		})
		if err != nil {
			return err
		}

		ctx.Export("vpcID", vpc_.ID())
		ctx.Export("instanceID", instance.ID())
		return nil
	})
}
