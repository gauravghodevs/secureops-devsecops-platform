# Evidence

Every claim of "verified" in the README should link to a dated file in this directory. Use this
naming pattern: `YYYY-MM-DD-topic.md`, containing the exact command, its output and the date.

## Checklist

- [x] GitHub Actions: [Workflow runs on GitHub Actions](https://github.com/gauravghodevs/secureops-devsecops-platform/actions)
- [x] Argo CD: [`2026-10-28-argocd-sync.md`](./2026-10-28-argocd-sync.md) (`Synced` and `Healthy`)
- [x] Alert delivery: [`alert-routing-drill.txt`](./alert-routing-drill.txt) (`deploy/alert-sink` firing alert)
- [ ] SonarQube: screenshot of the project and passed quality gate
- [x] Dependency-Track: [`dtrack-gate-run.txt`](./dtrack-gate-run.txt) (`scripts/dtrack_gate.py` output)
- [x] Terraform: [`terraform-aws-networking-plan.txt`](./terraform-aws-networking-plan.txt) and [`terraform-aws-compute-plan.txt`](./terraform-aws-compute-plan.txt)
- [x] Ansible: [`2026-10-28-ansible-hardening.md`](./2026-10-28-ansible-hardening.md)
- [x] OpenShift: [`2026-10-28-openshift-scc-verification.md`](./2026-10-28-openshift-scc-verification.md) (Kustomize overlay & security context verification)
- [x] Logging: [`2026-10-28-centralized-logging.md`](./2026-10-28-centralized-logging.md) (Elasticsearch & Fluent Bit `payment-api` log ingestion)
- [x] Two incident drills: [`kubernetes-deployment-rollback.md`](../incidents/kubernetes-deployment-rollback.md) and [`payment-api-kind-node-reboot.md`](../incidents/payment-api-kind-node-reboot.md)

Never commit tokens, keys, account IDs or real IP addresses. Redact them first.
