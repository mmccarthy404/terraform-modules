variable "name" {
  type        = string
  description = "Name of NAT instance and related infrastructure (overrides 'Name' tags)"
}

variable "instance_type" {
  type        = string
  default     = "t4g.nano"
  description = "Instance type of NAT instance (CPU architecture must be arm64 or x86_64)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch NAT instance"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tag keys and values to apply to NAT instance and related infrastrucure"
}