output "this" {
  value = {
    aws_security_group    = aws_security_group.this
    aws_network_interface = aws_network_interface.this
    aws_launch_template   = aws_launch_template.this
    aws_autoscaling_group = aws_autoscaling_group.this
  }
}