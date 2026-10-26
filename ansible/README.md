# Ansible Operations

## Inventory

`inventory/localhost.ini` targets localhost only and is used by the read-only audit playbook.
The hardening playbook targets the `[tooling]` group only, from a generated inventory:

```bash
terraform -chdir=../terraform/aws-compute output -raw ansible_inventory > inventory/hosts.ini
```

`inventory/hosts.ini` is git-ignored. See `inventory/hosts.ini.example`.

## Read-only audit

```bash
ansible-playbook -i ansible/inventory/localhost.ini ansible/playbooks/audit.yml
```

The audit gathers operating-system facts and reads root filesystem usage. It does not install
packages or change system configuration.

## Hardening (changes the host)

Run a dry run first, then apply, from the `ansible/` directory:

```bash
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/hardening.yml --check --diff
ansible-playbook -i inventory/hosts.ini playbooks/hardening.yml
```

The role updates packages, writes an SSH drop-in (key-only login, no root login, validated with
`sshd -t` before it is installed), applies kernel network settings and enables firewalld, auditd
and chrony. Verify afterwards with `sudo sshd -T | grep -Ei 'passwordauthentication|permitrootlogin'`
and `systemctl is-active firewalld auditd chronyd`. Record the output as evidence.

Test on a disposable host before applying to anything long-lived.
