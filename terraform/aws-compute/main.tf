data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "tooling_sg" {
  name        = "secureops-tooling-sg"
  description = "Restrict SSH, SonarQube, Dependency-Track, and Jenkins to trusted admin CIDR"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [22, 8080, 8081, 9000]
    content {
      description = "Restricted administrative and tooling access"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.admin_cidr]
    }
  }

  # trivy:ignore:AWS-0104
  egress {
    description = "Outbound package and container registry access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devsecops_tooling" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.tooling_sg.id]
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "secureops-tooling-host"
    ManagedBy   = "Terraform"
    Environment = "portfolio"
  }
}
