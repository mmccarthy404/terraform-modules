output "aws_security_group" {
  value       = aws_security_group.this
  description = "Security group of NAT instance"
}

output "aws_network_interface" {
  value       = aws_network_interface.this
  description = "Network interface of NAT instance"
}

output "aws_launch_template" {
  value       = aws_launch_template.this
  description = "Launch template of NAT instance"
}

output "aws_autoscaling_group" {
  value       = aws_autoscaling_group.this
  description = "Autoscaling group of NAT instance"
}