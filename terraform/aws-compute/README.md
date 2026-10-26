# AWS tooling host

One EC2 instance (Amazon Linux 2023) in a **public** subnet of the VPC from
`terraform/aws-networking`. It has a public IP and your SSH key, and SSH plus the tool ports are
open only to `admin_cidr`. Ansible then hardens it (`ansible/playbooks/hardening.yml`).

## Use

```bash
cd terraform/aws-compute
cp terraform.tfvars.example terraform.tfvars   # fill in vpc_id, subnet_id, admin_cidr
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output -raw ansible_inventory > ../../ansible/inventory/hosts.ini
```

## Cost and teardown

The instance bills while it exists, even when idle. Destroy it when you finish a session:

```bash
terraform destroy
```

## Security notes

- Ingress is limited to a single CIDR and `0.0.0.0/0` is rejected by validation.
- IMDSv2 is required and the root volume is encrypted.
- Egress is open so the host can reach package repositories; this is a documented, accepted
  finding (`trivy:ignore:AWS-0104`).
- State is local and git-ignored. Use an S3 backend with locking for shared work.
