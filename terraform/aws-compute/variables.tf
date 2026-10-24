variable "vpc_id" {
  description = "VPC ID from the aws-networking module."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the DevSecOps tooling host."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size for SonarQube, Dependency-Track, and Jenkins."
  type        = string
  default     = "t3.large"
}

variable "admin_cidr" {
  description = "Trusted VPN or internal CIDR block allowed to access SSH and tooling UIs."
  type        = string
}
