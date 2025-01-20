output "security_group" {
  value       = aws_security_group.this
  description = "Security group of WireGuard interface instance"
}

output "network_interface" {
  value       = aws_network_interface.this
  description = "Network interface of WireGuard interface instance"
}

output "iam_role" {
  value       = aws_iam_role.this
  description = "IAM role of WireGuard interface instance"
}

output "iam_instance_profile" {
  value       = aws_iam_instance_profile.this
  description = "IAM instance profile of WireGuard interface instance"
}

output "launch_template" {
  value       = aws_launch_template.this
  description = "Launch template of NAT instance"
}

output "autoscaling_group" {
  value       = aws_autoscaling_group.this
  description = "Autoscaling group of NAT instance"
}

output "wireguard_cidr" {
  value       = cidrsubnet(var.wireguard_interface_address, 0, 0)
  description = "WireGuard CIDR"
}