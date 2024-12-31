data "aws_ec2_instance_type" "selected" {
  instance_type = var.instance_type

  lifecycle {
    # CPU architecture must be arm64 or x86_64
    postcondition {
      condition     = contains(self.supported_architectures, "arm64") || contains(self.supported_architectures, "x86_64")
      error_message = "CPU architecture must be arm64 or x86_64"
    }
  }
}

data "aws_ami" "fck_nat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["fck-nat-amzn2-*"]
  }

  filter {
    name   = "architecture"
    values = data.aws_ec2_instance_type.selected.supported_architectures
  }
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = var.name
  vpc_id      = data.aws_vpc.selected.id

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}

resource "aws_vpc_security_group_ingress_rule" "cidr_block" {
  description       = "Allow all traffic from VPC CIDR block into ${var.name}-sg"
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = data.aws_vpc.selected.cidr_block
  ip_protocol = "-1"

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "all" {
  description       = "Allow all traffic out of ${var.name}-sg"
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = var.tags
}

resource "aws_network_interface" "this" {
  description     = "${var.name}-eni"
  subnet_id       = data.aws_subnet.selected.id
  security_groups = [aws_security_group.this.id]

  source_dest_check = false

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}

resource "aws_iam_role" "this" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
  ])

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.this.name

  tags = var.tags
}

resource "aws_launch_template" "this" {
  name          = "${var.name}-lt"
  image_id      = data.aws_ami.fck_nat.id
  instance_type = var.instance_type

  network_interfaces {
    network_interface_id = aws_network_interface.this.id
  }

  metadata_options {
    http_tokens = "required"
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "this" {
  name               = "${var.name}-asg"
  availability_zones = [data.aws_subnet.selected.availability_zone]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = { for k, v in var.tags : k => v if k != "Name" }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}