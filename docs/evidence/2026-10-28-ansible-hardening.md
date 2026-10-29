# Ansible Hardening & Audit Verification (2026-10-28)

## 1. Read-Only Audit Playbook Output
```text
$ ansible-playbook -i ansible/inventory/localhost.ini ansible/playbooks/audit.yml
PLAY [Audit Linux hosts for SecureOps] ***********************************************
TASK [Gathering Facts] ***************************************************************
ok: [localhost]
TASK [Display host and operating system details] *************************************
ok: [localhost] => {
    "msg": [
        "Host: localhost",
        "OS family: RedHat",
        "Distribution: OracleLinux",
        "Version: 8.10",
        "Architecture: x86_64"
    ]
}
TASK [Check available disk space on root filesystem] *********************************
ok: [localhost]
TASK [Report root filesystem usage] **************************************************
ok: [localhost] => {
    "root_disk.stdout_lines": [
        "Filesystem     1024-blocks    Used Available Capacity Mounted on",
        "/dev/sdd        1055762868 9002656 993056740       1% /"
    ]
}
PLAY RECAP ***************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## 2. Hardening Playbook Validation
- Syntax check verified: `ansible-playbook -i ansible/inventory/hosts.ini.example ansible/playbooks/hardening.yml --syntax-check`
- Role targets `[tooling]` inventory group exclusively to prevent unintended local host reconfiguration.
- Configures SSH hardening drop-in (`/etc/ssh/sshd_config.d/01-hardening.conf`) with `PermitRootLogin no`, `PasswordAuthentication no`, and `validate: /usr/sbin/sshd -t -f %s`.
- Applies kernel network sysctl parameters (`/etc/sysctl.d/90-hardening.conf`) and enables `firewalld`, `auditd`, and `chronyd`.
