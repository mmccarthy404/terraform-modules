data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = data.aws_ec2_instance_type.this.supported_architectures
  }
}

data "aws_subnet" "this" {
  id = var.subnet_id
}

data "aws_vpc" "this" {
  id = data.aws_subnet.this.vpc_id
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = var.name
  vpc_id      = data.aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = toset(distinct(flatten([for peer in var.wireguard_interface_peers : peer.allowed_ips])))

  description       = "Allow UDP traffic from ${each.key} into ${var.name}-sg"
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = each.key
  ip_protocol = "udp"

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "this" {
  description       = "Allow all traffic out of ${var.name}-sg"
  security_group_id = aws_security_group.this.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = var.tags
}

resource "aws_network_interface" "this" {
  description     = "${var.name}-eni"
  subnet_id       = data.aws_subnet.this.id
  security_groups = [aws_security_group.this.id]

  source_dest_check = false

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}

resource "aws_eip_association" "this" {
  allocation_id        = var.elastic_ip
  network_interface_id = aws_network_interface.this.id
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
  image_id      = data.aws_ami.wireguard.id
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

  user_data = base64encode(templatefile("${path.module}/files/user-data.sh", {
    interface_private_key = var.wireguard_interface_private_key
    interface_address     = var.wireguard_interface_address
    interface_listen_port = var.wireguard_interface_listen_port
    interface_dns         = var.wireguard_interface_dns
    interface_post_up     = var.wireguard_interface_post_up
    interface_post_down   = var.wireguard_interface_post_down
    interface_peers       = var.wireguard_interface_peers
  }))

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}

resource "aws_autoscaling_group" "this" {
  name               = "${var.name}-asg"
  availability_zones = [data.aws_subnet.this.availability_zone]
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