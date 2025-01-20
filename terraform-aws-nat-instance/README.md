# Terraform Module: terraform-aws-nat-instance

## Overview

This Terraform module deploys a NAT instance using [Andrew Guenther's fck_nat AMI](https://github.com/AndrewGuenther/fck-nat). The NAT instance is created as part of an autoscaling group to ensure automated disaster recovery. For production workloads, best practice is to use a NAT gateway for [better availability and bandwidth](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html); **I do not recommend this module for production workloads**. 

## Usage

```hcl
# Create NAT instance in public subnet
module "nat_instance" {
  source        = "git::https://github.com/mmccarthy404/terraform-modules//terraform-aws-nat-instance?ref=d6f5e426d617778ec41e7ff63e427478541e0dda" #v2.2.1
  instance_type = "t4g.nano"
  name          = "nat-instance"
  subnet_id     = "subnet-xxxxxxxxxxxxxxxxx" # public subnet

  tags = {
    terraform   = "true"
    project     = "vpc-project"
    environment = "dev"
  }
}

# Define list of all route tables in selected VPC to route to NAT instance 
locals {
  route_table_ids = ["rtb-xxxxxxxxxxxxxxxxx", "rtb-yyyyyyyyyyyyyyyyy"] # one or more route table IDs
}

# Create route(s) to NAT instance ENI in root table(s)
resource "aws_route" "nat_instance" {
  for_each = toset(local.route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat_instance.network_interface.id
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.50 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.50 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_network_interface.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.cidr_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.fck_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_instance_type.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of NAT instance (CPU architecture must be arm64 or x86\_64) | `string` | `"t4g.nano"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of NAT instance and related infrastructure (overrides 'Name' tags) | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID to launch NAT instance | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tag keys and values to apply to NAT instance and related infrastrucure | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group"></a> [autoscaling\_group](#output\_autoscaling\_group) | Autoscaling group of NAT instance |
| <a name="output_launch_template"></a> [launch\_template](#output\_launch\_template) | Launch template of NAT instance |
| <a name="output_network_interface"></a> [network\_interface](#output\_network\_interface) | Network interface of NAT instance |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | Security group of NAT instance |
<!-- END_TF_DOCS -->

## Note

This module requires that the fck_nat AMI is [available in the selected AWS region](https://github.com/AndrewGuenther/fck-nat/blob/main/packer/fck-nat-public-all-regions.pkrvars.hcl) for successful deployment.

## Licence

This Terraform module is open source and available under the [MIT License](https://github.com/mmccarthy404/terraform-modules/blob/main/LICENSE).
