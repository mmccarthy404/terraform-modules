variable "name" {
  type        = string
  description = "Name of WireGuard interface instance and related infrastructure (overrides 'Name' tags)"
}

variable "instance_type" {
  type        = string
  default     = "t4g.nano"
  description = "Instance type of WireGuard interface instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch WireGuard interface instance"
}

variable "elastic_ip" {
  type        = string
  description = "Elastic IP _allocation ID for the WireGuard interface instance"
}

variable "wireguard_interface_private_key" {
  sensitive   = true
  type        = string
  description = "WireGuard interface private key"
}

variable "wireguard_interface_address" {
  type        = string
  default     = "192.168.2.1/24"
  description = "WireGuard interface address"
}

variable "wireguard_interface_listen_port" {
  type        = number
  default     = 51820
  description = "WireGuard interface listen port"
}

variable "wireguard_interface_dns" {
  type        = string
  default     = "8.8.8.8"
  description = "WireGuard interface DNS"
}

variable "wireguard_interface_post_up" {
  type        = string
  default     = "iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
  description = "WireGuard interface PostUp script"
}

variable "wireguard_interface_post_down" {
  type        = string
  default     = "iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"
  description = "WireGuard interface PostDown script"
}

variable "wireguard_peer_public_key" {
  sensitive   = true
  type        = string
  description = "WireGuard peer public key"
}

variable "wireguard_peer_allowed_ip" {
  type        = string
  default     = "192.168.2.2/32"
  description = "WireGuard peer allowed IP"
}

variable "wireguard_peer_source_ip" {
  sensitive   = true
  type        = string
  description = "Source IP of WireGuard peer (peer public IP)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tag keys and values to apply to WireGuard interface instance and related infrastructure"
}