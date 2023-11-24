variable "name_prefix" {
  type        = string
  description = "Prefix used when naming NAT instance and related infrastructure"
}

variable "instance_type" {
  type        = string
  default     = "t4g.nano"
  description = "Instance type of deployed NAT instance (CPU architecture must be arm64 or x86_64)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to launch NAT instance in"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch NAT instance in"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tag keys and values to apply to NAT instance and related infrastrucure"
}