# Terraform Module: terraform-aws-nat-instance

## Overview

This Terraform module deploys a [Wireguard](https://www.wireguard.com/) interface instance into a select public subnet to function as a VPN, enabling access to resources in private subnets from peers. The Wireguard interface instance is created as part of an autoscaling group to ensure automated disaster recovery, and a required elastic IP ensures that connections to peers are preserved though this recovery.

## Usage

```hcl
```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->

## Note

This module only manages the Wireguard interface acting as the VPN server in AWS, and all peers must be configured manually. Additionally it is prerequisite that  all [Wireguard keys](https://www.wireguard.com/quickstart/#key-generation) be generated externally and supplied as variables before deployment.

## Licence

This Terraform module is open source and available under the [MIT License](https://github.com/mmccarthy404/terraform-modules/blob/main/LICENSE).
