output "tooling_private_ip" {
  description = "Private IP of the SecureOps tooling host."
  value       = aws_instance.devsecops_tooling.private_ip
}

output "tooling_security_group_id" {
  description = "Security group ID attached to the tooling host."
  value       = aws_security_group.tooling_sg.id
}
