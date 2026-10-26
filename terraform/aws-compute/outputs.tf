output "tooling_public_ip" {
  description = "Public IP of the tooling host (reachable only from admin_cidr)."
  value       = aws_instance.devsecops_tooling.public_ip
}

output "tooling_private_ip" {
  description = "Private IP of the SecureOps tooling host."
  value       = aws_instance.devsecops_tooling.private_ip
}

output "tooling_security_group_id" {
  description = "Security group ID attached to the tooling host."
  value       = aws_security_group.tooling_sg.id
}

output "ssh_command" {
  value = "ssh ${var.ssh_user}@${aws_instance.devsecops_tooling.public_ip}"
}

# terraform output -raw ansible_inventory > ../../ansible/inventory/hosts.ini
output "ansible_inventory" {
  value = <<-EOT
    [tooling]
    ${aws_instance.devsecops_tooling.public_ip} ansible_user=${var.ssh_user}
  EOT
}
