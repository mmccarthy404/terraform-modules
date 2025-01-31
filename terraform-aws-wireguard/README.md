# Terraform Module: terraform-aws-nat-instance

## Overview

This Terraform module deploys a [WireGuard](https://www.wireguard.com/) interface instance into a select public subnet to function as a VPN, enabling access to resources in private subnets from peers. The WireGuard interface instance is created as part of an autoscaling group to ensure automated disaster recovery, and a required externally-managed elastic IP ensures that connections to peers are preserved though this recovery.

## Usage

Client WireGuard interface should be manually configured as `client.conf`:

```ini
[Interface]
PrivateKey = <WireGuard client interface private key>
Address = 192.168.2.2/32 # IP address should match that specified by var.wireguard_peer_allowed_ip

[Peer]
PublicKey = <WireGuard server interface public key>
Endpoint = <public IP of WireGuard interface instance>:51820 # Port should match that specified by wireguard_interface_listen_port
AllowedIPs = 10.0.0.0/16, 192.168.2.0/24 # Allowed IPs should match both AWS VPC CIDR and WireGuard VPC CIDR specified by var.wireguard_interface_address
```

Server WireGuard interface is created with this Terraform module:

```hcl
# Create example tags as a local
locals {
  tags = {
    terraform   = "true"
    project     = "aws-networking"
    environment = "prd"
  }
}

# Create EIP outside of WireGuard module to separate life cycles, allowing EIPs to be kept even if WireGuard module is destroyed
resource "aws_eip" "wireguard" {
  domain = "vpc"

  tags = local.tags
}

# Create WireGuard interface VPN enabling access to private subnets from peered interfaces
module "wireguard" {
  source        = "git::https://github.com/mmccarthy404/terraform-modules//terraform-aws-wireguard?ref=7262f775270c0e0f8499b5ae51dba30da41d7cca" #v2.2.4
  instance_type = "t4g.nano"
  name          = "wireguard-instance"
  subnet_id     = "subnet-xxxxxxxxxxxxxxxxx" # public subnet

  elastic_ip = aws_eip.wireguard.id

  wireguard_interface_private_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=" # Treat this value as sensitive
  wireguard_peer_public_key       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=" # Treat this value as sensitive
  wireguard_peer_source_ip        = "x.x.x.x/32" # Treat this value as sensitive

  tags = local.tags
}

# Define list of all route tables in selected VPC to route to WireGuard instance 
locals {
  route_table_ids = ["rtb-xxxxxxxxxxxxxxxxx", "rtb-yyyyyyyyyyyyyyyyy"] # one or more route table IDs
}

# Create route(s) to WireGuard instance ENI in root table(s)
resource "aws_route" "wireguard_instance" {
  for_each = toset(local.route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = module.wireguard.wireguard_cidr
  network_interface_id   = module.wireguard.aws_network_interface.id
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
| [aws_eip_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_network_interface.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_instance_type.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_elastic_ip"></a> [elastic\_ip](#input\_elastic\_ip) | Elastic IP \_allocation ID for the WireGuard interface instance | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of WireGuard interface instance | `string` | `"t4g.nano"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of WireGuard interface instance and related infrastructure (overrides 'Name' tags) | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID to launch WireGuard interface instance | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tag keys and values to apply to WireGuard interface instance and related infrastructure | `map(string)` | `{}` | no |
| <a name="input_wireguard_interface_address"></a> [wireguard\_interface\_address](#input\_wireguard\_interface\_address) | WireGuard interface address | `string` | `"192.168.2.1/24"` | no |
| <a name="input_wireguard_interface_dns"></a> [wireguard\_interface\_dns](#input\_wireguard\_interface\_dns) | WireGuard interface DNS | `string` | `"8.8.8.8"` | no |
| <a name="input_wireguard_interface_listen_port"></a> [wireguard\_interface\_listen\_port](#input\_wireguard\_interface\_listen\_port) | WireGuard interface listen port | `number` | `51820` | no |
| <a name="input_wireguard_interface_post_down"></a> [wireguard\_interface\_post\_down](#input\_wireguard\_interface\_post\_down) | WireGuard interface PostDown script | `string` | `"iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"` | no |
| <a name="input_wireguard_interface_post_up"></a> [wireguard\_interface\_post\_up](#input\_wireguard\_interface\_post\_up) | WireGuard interface PostUp script | `string` | `"iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"` | no |
| <a name="input_wireguard_interface_private_key"></a> [wireguard\_interface\_private\_key](#input\_wireguard\_interface\_private\_key) | WireGuard interface private key | `string` | n/a | yes |
| <a name="input_wireguard_peer_allowed_ip"></a> [wireguard\_peer\_allowed\_ip](#input\_wireguard\_peer\_allowed\_ip) | WireGuard peer allowed IP | `string` | `"192.168.2.2/32"` | no |
| <a name="input_wireguard_peer_public_key"></a> [wireguard\_peer\_public\_key](#input\_wireguard\_peer\_public\_key) | WireGuard peer public key | `string` | n/a | yes |
| <a name="input_wireguard_peer_source_ip"></a> [wireguard\_peer\_source\_ip](#input\_wireguard\_peer\_source\_ip) | Source IP of WireGuard peer (peer public IP) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group"></a> [autoscaling\_group](#output\_autoscaling\_group) | Autoscaling group of NAT instance |
| <a name="output_iam_instance_profile"></a> [iam\_instance\_profile](#output\_iam\_instance\_profile) | IAM instance profile of WireGuard interface instance |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | IAM role of WireGuard interface instance |
| <a name="output_launch_template"></a> [launch\_template](#output\_launch\_template) | Launch template of NAT instance |
| <a name="output_network_interface"></a> [network\_interface](#output\_network\_interface) | Network interface of WireGuard interface instance |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | Security group of WireGuard interface instance |
| <a name="output_wireguard_cidr"></a> [wireguard\_cidr](#output\_wireguard\_cidr) | WireGuard CIDR |
<!-- END_TF_DOCS -->

## Note

This module only manages the WireGuard interface acting as the VPN server in AWS, and all peers must be configured manually. Additionally it is prerequisite that  all [WireGuard keys](https://www.wireguard.com/quickstart/#key-generation) be generated externally and supplied as variables before deployment.

## Licence

This Terraform module is open source and available under the [MIT License](https://github.com/mmccarthy404/terraform-modules/blob/main/LICENSE).
