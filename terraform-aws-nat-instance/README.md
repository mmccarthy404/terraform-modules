# Terraform Module: terraform-aws-nat-instance

## Overview

This Terraform module deploys a NAT instance using [Andrew Guenther's fck_nat AMI](https://github.com/AndrewGuenther/fck-nat). The NAT instance is created as part of an autoscaling group to ensure automated disaster recovery.

## Usage

```hcl
# Create NAT instance in public subnet
module "nat_instance" {
  source        = "git::https://github.com/mmccarthy404/terraform-modules//terraform-aws-nat-instance?ref=483e821adf1164dde52652c793aec558294ed6e3" #v1.0.0
  instance_type = "t4g.nano"
  name_prefix   = "nat-instance"
  vpc_id        = "vpc-xxxxxxxxxxxxxxxxx"
  subnet_id     = "subnet-xxxxxxxxxxxxxxxxx" # public subnet

  tags = {
    terraform   = "true"
    project     = "vpc-project"
    environment = "prd"
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
  network_interface_id   = module.nat_instance.this.aws_network_interface.id
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
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of deployed NAT instance (CPU architecture must be arm64 or x86\_64) | `string` | `"t4g.nano"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when naming NAT instance and related infrastructure | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID to launch NAT instance in | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tag keys and values to apply to NAT instance and related infrastrucure | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to launch NAT instance in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this"></a> [this](#output\_this) | n/a |
<!-- END_TF_DOCS -->

## Note

This module requires that the fck_nat AMI is [available in the selected AWS region](https://github.com/AndrewGuenther/fck-nat/blob/main/packer/fck-nat-public-all-regions.pkrvars.hcl) for successful deployment.

## Licence

This Terraform module is open source and available under the [MIT License](https://github.com/mmccarthy404/terraform-modules/blob/main/LICENSE).