provider "aws" {
  region = var.region
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Without a key pair there is no way to log in to an Amazon Linux host.
resource "aws_key_pair" "tooling" {
  key_name_prefix = "secureops-tooling-"
  public_key      = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_security_group" "tooling_sg" {
  name        = "secureops-tooling-sg"
  description = "SSH and tool UIs, restricted to one trusted admin CIDR"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = {
      ssh        = 22
      jenkins    = 8080
      dtrack_api = 8081
      dtrack_ui  = 8082
      sonarqube  = 9000
    }
    content {
      description = ingress.key
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

  tags = {
    Name = "secureops-tooling-sg"
  }
}

resource "aws_instance" "devsecops_tooling" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.tooling_sg.id]
  key_name                    = aws_key_pair.tooling.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "secureops-tooling-host"
    ManagedBy   = "Terraform"
    Environment = "portfolio"
  }
}
