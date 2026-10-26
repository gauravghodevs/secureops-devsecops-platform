variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_id" {
  description = "VPC ID from the aws-networking module (terraform output -raw vpc_id)."
  type        = string
}

variable "subnet_id" {
  description = "A PUBLIC subnet ID from the aws-networking module."
  type        = string
}

variable "instance_type" {
  description = "8 GB RAM (t3.large) is the practical minimum for SonarQube + Dependency-Track + Jenkins."
  type        = string
  default     = "t3.large"
}

variable "root_volume_gb" {
  type    = number
  default = 40
}

variable "admin_cidr" {
  description = "Your public IP as a /32 (curl -s https://checkip.amazonaws.com). Never 0.0.0.0/0."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must be a valid IPv4 CIDR and must not be 0.0.0.0/0."
  }
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "ssh_user" {
  description = "Login user of the AMI (Amazon Linux 2023 = ec2-user); only used to render the inventory."
  type        = string
  default     = "ec2-user"
}
