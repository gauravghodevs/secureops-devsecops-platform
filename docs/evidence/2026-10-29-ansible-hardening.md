# Ansible Hardening Verification — 2026-10-29

## Scope and safety

SSH hardening was tested in a disposable Rocky Linux 9 container using
Ansible's Docker connection plugin. The full hardening role was not applied
to the active WSL host.

## Remaining verification

- [ ] Capture full-role `--check --diff` output in a suitable isolated VM.
- [ ] Capture full-role apply output in that VM.
- [ ] Verify service-management, sysctl, and SELinux behavior in that environment.

The selected-task container test does not count as a full-role apply.
The transcripts below summarize observed output; they are not byte-for-byte
terminal captures. The full-role verification remains pending.

## 8. Captured test output details

### 8.1 Selected-task check-mode run

Command:
```bash
ansible-playbook -i ansible/inventory/container-test.ini ansible/playbooks/hardening-container-check.yml --diff
```

Captured terminal output:
```text
PLAY [Safely check selected hardening tasks in the test container]

TASK [Gathering Facts]
ok: [secureops-hardening-test]

TASK [Apply pending security updates]
changed: [secureops-hardening-test]

TASK [Install baseline security packages]
ok: [secureops-hardening-test]

TASK [Harden the SSH daemon]
changed: [secureops-hardening-test]

PLAY RECAP
secureops-hardening-test : ok=4 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

Note: This is a transcript of the observed task output, not a byte-for-byte
terminal capture. The `changed` statuses in check mode indicate proposed
changes. The original configuration diff was observed but is not reproduced
as a complete raw log here.

### 8.2 SSH hardening apply in disposable container

Command:
```bash
ansible-playbook -i ansible/inventory/container-test.ini ansible/playbooks/ssh-hardening-container-test.yml --diff
```

Captured terminal output:
```text
PLAY [Apply SSH hardening in disposable container only]

TASK [Gathering Facts]
ok: [secureops-hardening-test]

TASK [Harden the SSH daemon]
changed: [secureops-hardening-test]

PLAY RECAP
secureops-hardening-test : ok=2 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

### 8.3 Effective SSH configuration verification

Command:
```bash
docker exec secureops-hardening-test /usr/sbin/sshd -T | grep -E '^(permitrootlogin|passwordauthentication|kbdinteractiveauthentication|permitemptypasswords|x11forwarding|maxauthtries|logingracetime) '
```

Observed output:
```text
logingracetime 30
maxauthtries 3
permitrootlogin no
passwordauthentication no
kbdinteractiveauthentication no
x11forwarding no
permitemptypasswords no
```

### 8.4 SSH configuration file ownership and permissions

Command:
```bash
docker exec secureops-hardening-test stat -c '%U:%G %a %n' /etc/ssh/sshd_config.d/01-hardening.conf
```

Observed output:
```text
root:root 600 /etc/ssh/sshd_config.d/01-hardening.conf
```

### 8.5 SSH syntax validation

Command:
```bash
docker exec secureops-hardening-test /usr/sbin/sshd -t
```

Observed result: exited successfully with no output.

### 8.6 Test cleanup

Command:
```bash
docker rm -f secureops-hardening-test
```

Observed output:
```text
secureops-hardening-test
```

### 8.7 Verification boundary

These results document selected hardening tasks and SSH configuration
verification in a disposable container. They are not full-role check-mode
or apply logs. Full-role validation and application, including sysctl,
service-management, and SELinux behavior, remain pending in an isolated
systemd-capable test VM. The active WSL host was not used as the target.
