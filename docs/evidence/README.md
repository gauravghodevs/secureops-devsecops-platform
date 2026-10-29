# Evidence

Every claim of "verified" in the README should link to a dated file in this directory. Use this
naming pattern: `YYYY-MM-DD-topic.md`, containing the exact command, its output and the date.

## Checklist

- [ ] GitHub Actions: link to a green run of each workflow on `main`
- [ ] Argo CD: `argocd app list` showing `Synced` and `Healthy`
- [ ] Alert delivery: `kubectl -n monitoring logs deploy/alert-sink` showing a firing alert
- [ ] SonarQube: screenshot of the project and passed quality gate
- [ ] Dependency-Track: screenshot of the project, and the gate output from `scripts/dtrack_gate.py`
- [ ] Terraform: `terraform plan` and `apply` output, then `terraform destroy` output
- [x] Ansible: selected-task check-mode output, isolated-container SSH apply, effective `sshd -T` settings, and file-permission verification documented in `2026-10-29-ansible-hardening.md` (full-role VM verification pending)
- [ ] OpenShift: output from `docs/operations/openshift-deployment.md`
- [ ] Logging: Kibana screenshot showing `payment-api` log lines
- [ ] Two incident drills with symptoms, commands, root cause, fix and prevention

Never commit tokens, keys, account IDs or real IP addresses. Redact them first.
