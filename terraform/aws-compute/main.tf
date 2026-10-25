# Terraform AWS Compute Module with Trivy suppressions for required egress
resource "aws_security_group" "tooling_sg" {
  name        = "secureops-tooling-sg"
  description = "Security group for DevOps tooling server"
  vpc_id      = var.vpc_id

  ingress {
    description = "Admin SSH/HTTPS access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # trivy:ignore:AWS-0104
  egress {
    description = "Allow all outbound traffic for package updates and tooling"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secureops-tooling-sg"
  }
}

resource "aws_instance" "tooling" {
  ami           = "ami-0c55b159cbfafe1f0" # Placeholder AMI
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [
    aws_security_group.tooling_sg.id
  ]

  root_block_device {
    encrypted   = true
    volume_size = 30
  }

  tags = {
    Name = "secureops-tooling-server"
  }
}
