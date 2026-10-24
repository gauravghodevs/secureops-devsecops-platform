variable "vpc_id" {
  type        = string
  description = "VPC ID from aws-networking module"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for tooling VM"
}

variable "instance_type" {
  type        = string
  default     = "t3.large"
}
