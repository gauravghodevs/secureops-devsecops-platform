output "tooling_public_ip" {
  value       = aws_instance.devsecops_tooling.public_ip
  description = "Public IP of tooling host"
}
