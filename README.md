# SecureOps — Enterprise DevSecOps Platform

A production-oriented DevSecOps portfolio project demonstrating secure application delivery, containerization, Kubernetes operations, infrastructure automation, security gates, GitOps, observability, and production troubleshooting.

> **Implementation status:** built incrementally. This README distinguishes verified implementation from planned platform capabilities.

## Project Overview

SecureOps simulates an enterprise financial-services environment where application teams need a standardized and secure software delivery platform.

The engineering goal is to build a delivery path that is:

- repeatable
- testable
- security-aware
- observable
- recoverable
- suitable for Kubernetes/OpenShift environments

## Current Implementation

The following capabilities are implemented and tested today:

| Capability | Status | Evidence |
|---|---|---|
| FastAPI payment service | Implemented | `applications/payment-api` |
| Automated API tests | Implemented | pytest test suite |
| Docker containerization | Implemented | `applications/payment-api/Dockerfile` |
| Container security scanning | Implemented | Trivy image scanning |
| Kubernetes Deployment | Implemented | 2 replicas on Kind |
| Kubernetes Service | Implemented | ClusterIP service |
| Health/readiness probes | Implemented | `/health`, `/ready` |
| Resource requests/limits | Implemented | Deployment manifest |
| Prometheus metrics | Implemented | `/metrics` (`/metrics/` redirects to it) |
| Kustomize base | Implemented | `kubernetes/base` |
| OpenShift deployment | Manifests prepared (Route, ServiceMonitor, own project); not yet deployed to a live OpenShift cluster | `kubernetes/overlays/openshift`, `argocd/openshift/` |
| Jenkins pipeline | Configured and previously verified successful | `ci/jenkins/Jenkinsfile` |
| Tekton | Separate clone, test, SBOM/SCA, and build/config-scan tasks are defined; end-to-end execution of all stages still needs evidence | `ci/tekton/payment-api-pipeline.yaml` |
| SAST quality gate | SonarCloud gate runs in GitHub Actions; self-hosted SonarQube is configured for Tekton but not yet executed | `.github/workflows/payment-api-ci.yml`, `ci/tekton/payment-api-secure-pipeline.yaml`, `tools/` |
| CycloneDX SBOM generation | Implemented | `.github/workflows/dependency-supply-chain.yml` |
| Dependency-Track SCA gate | Gate script and Tekton task are written and unit-tested; no Dependency-Track run recorded yet | `scripts/dtrack_gate.py`, `tools/` |
| Argo CD GitOps | Implemented and verified | `argocd/` |
| Terraform AWS infrastructure | Networking and compute modules plus CI validation are configured; AWS provisioning is not verified | `terraform/` and infrastructure workflow |
| Ansible configuration management | Audit and hardening playbooks/roles are configured; host-level application is not verified | `ansible/` and infrastructure workflow |
| Prometheus / Grafana / Alertmanager | Pods and Argo CD monitoring application were healthy in the latest reported Kind check; alert delivery still needs verification | `observability/` |
| Centralized logging (Fluent Bit, Elasticsearch, Kibana) | Manifests written; not yet deployed or verified | `logging/` |

## Architecture Target

The target platform architecture is:

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins / Tekton
    |
    +--> Unit Tests
    +--> SonarQube (SAST)
    +--> Dependency-Track / SBOM
    +--> Trivy
    |
    v
Docker Build
    |
    v
Container Registry
    |
    v
GitOps
    |
    v
Argo CD
    |
    v
OpenShift / Kubernetes
    |
    +--> payment-api (first application; further services are future work)
    |
    +--> Prometheus
    +--> Grafana
    +--> Alertmanager
    |
    +--> Fluent Bit -> Logstash -> Elasticsearch -> Kibana

Terraform -> AWS infrastructure
Ansible  -> Linux configuration and hardening
```

> The architecture above is the **target design**. Individual components are marked implemented only after they are built and verified.

## Implemented Application: payment-api

The first application is a small FastAPI service designed to exercise the platform delivery path.

### Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Service status |
| `/health` | Liveness health check |
| `/ready` | Readiness check |
| `/metrics` | Prometheus metrics (`/metrics/` redirects here) |

Example service response:

```json
{"service":"payment-api","status":"running"}
```

### Application structure

```text
applications/payment-api/
├── app/
│   ├── __init__.py
│   ├── main.py              # shipped in the image
│   ├── secret_factory.py    # optional secrets provider (not shipped in the image)
│   └── secrets.py
├── tests/
├── Dockerfile
├── pytest.ini
├── requirements.txt         # direct runtime dependencies
├── requirements.lock        # hash-locked runtime dependencies used by the image build
├── requirements-dev.txt
├── requirements-dev.lock
└── sonar-project.properties
```

## Kubernetes

The payment API is deployed to a local Kind cluster with:

- 2 replicas
- ClusterIP Service
- CPU and memory requests/limits
- HTTP readiness probe
- HTTP liveness probe
- Prometheus scrape annotations
- Kustomize-managed base manifests

Verified deployment flow:

```text
Docker Image
    |
    v
Kind Cluster
    |
    v
Deployment
    |
    +--> Pod
    +--> Pod
    |
    v
ClusterIP Service
    |
    v
Application
```

### Runtime Container Hardening

The `payment-api` Deployment applies Kubernetes container security controls:

- `runAsNonRoot: true` — prevents the container from running as root.
- The base Deployment does not hardcode `runAsUser`, allowing platforms such as OpenShift to assign a namespace-approved UID; OpenShift runtime compatibility still requires a real deployment test.
- `allowPrivilegeEscalation: false` — disables privilege escalation.
- `capabilities.drop: [ALL]` — drops all Linux capabilities from the container.
- `seccompProfile.type: RuntimeDefault` — uses the container runtime's default seccomp profile.

**Runtime verification:** The rollout completed successfully with 2/2 replicas ready. Both new pods reported zero restarts at verification time. The `/health`, `/ready`, and `/metrics` returned HTTP 200. `/metrics/` redirects to `/metrics`.

## Security Engineering

Container images are scanned with Trivy as part of the development workflow.

The project treats security scanning as an engineering gate rather than a documentation checkbox.

Important distinction:

- **0 OS HIGH/CRITICAL findings** were observed for the verified `payment-api:0.3.0` image scan.
- The same scan reported Python-package/vendor metadata findings.
- Those findings were investigated rather than hidden or falsely reported as zero vulnerabilities.

This project intentionally documents security findings and their context instead of suppressing them merely to produce a clean badge.

## Implemented CI and Security Workflows

GitHub Actions workflows are configured for application CI, Kubernetes security, secret scanning, dependency review, dependency auditing and SBOM generation, and documentation validation.

The application CI workflow includes automated tests and linting, Kubernetes manifest validation, container build and smoke tests, and Trivy image scanning. The dependency supply-chain workflow audits Python dependencies and generates a CycloneDX SBOM.

### Container Image Security Gate

The Payment API CI workflow scans the built container image with Trivy for OS and application-library vulnerabilities. The blocking scan is configured for **HIGH** and **CRITICAL** severity findings and ignores unfixed vulnerabilities. A blocking finding fails the workflow before the image-publishing step; the workflow also uploads human-readable and JSON reports for investigation.

Latest verified evidence (2026-10-21): the [Payment API CI run](https://github.com/gauravghodevs/secureops-devsecops-platform/actions/runs/39586445574) completed successfully. Its uploaded Trivy reports recorded **zero detected vulnerabilities** in the scanned OS and Python package results. This is a point-in-time result for that image and vulnerability database, not a guarantee that the image is vulnerability-free. Review the report artifact from the workflow run when investigating findings.

Jenkins pipeline execution has previously been verified successfully. The Tekton payment API pipeline has also been executed successfully: source cloning, Ruff linting, and the test suite passed. Argo CD synchronization has been verified in the live cluster.

Workflow configuration and execution results are separate evidence. Check the relevant GitHub Actions run before claiming a gate passed.

## Infrastructure Automation Status

### Terraform

Target AWS infrastructure includes:

- VPC
- subnets
- security groups
- IAM
- EC2

### Ansible

Target configuration-management responsibilities include:

- Linux configuration
- Docker installation/configuration
- Node Exporter
- security hardening
- operational configuration

The Terraform and Ansible configuration files exist and their validation is wired into CI. This is not evidence that AWS resources were applied or that hardening was executed against a managed host.

## Observability and Logging

### Implemented Metrics and Alerting

Validation evidence: [Prometheus Alerting Validation](docs/observability/prometheus-alerting-validation.md).

```text
Application / Kubernetes
        |
        v
   Prometheus
        |
        +--> Grafana
        |
        +--> Alertmanager
```

### Planned Centralized Logging

```text
Application Logs
      |
      v
 Fluent Bit
      |
      v
 Logstash
      |
      v
Elasticsearch
      |
      v
  Kibana
```

## Production Troubleshooting Scenarios

The project will document practical incident-response scenarios such as:

1. CrashLoopBackOff
2. failed security gate
3. high CPU or memory utilization
4. GitOps configuration drift
5. failed deployment and rollback

Each scenario is intended to include:

- symptoms
- investigation commands
- evidence
- root cause
- remediation
- preventive controls

### Documented Incident Runbooks

- [Kubernetes Deployment rollback](docs/incidents/kubernetes-deployment-rollback.md)
- [Payment API Kind node reboot incident](docs/incidents/payment-api-kind-node-reboot.md)
- [Monitoring stack deployment and verification](docs/operations/monitoring-stack-deployment.md)

## Technology Stack

| Area | Technologies |
|---|---|
| Version control | Git, GitHub |
| Application | Python, FastAPI |
| Testing | pytest |
| Containers | Docker |
| Orchestration | Kubernetes, OpenShift |
| Local platform | Kind |
| CI/CD | Jenkins, Tekton |
| GitOps | Argo CD |
| Cloud | AWS |
| IaC | Terraform |
| Configuration management | Ansible |
| SAST | SonarQube |
| SCA / SBOM | Dependency-Track, CycloneDX |
| Container security | Trivy |
| Monitoring | Prometheus, Grafana |
| Alerting | Alertmanager |
| Logging | Fluent Bit, Logstash, Elasticsearch, Kibana |
| Operating system | Linux |
| Automation | Python, Bash |

## Repository Structure

```text
secureops-devsecops-platform/
├── applications/payment-api/   FastAPI service, tests, Dockerfile, dependency locks
├── ansible/                    audit and hardening playbooks, hardening role
├── argocd/                     Argo CD project apps (Kind) and argocd/openshift
├── ci/                         Jenkins and Tekton pipelines
├── docs/                       runbooks, incidents, security reviews, evidence
├── kubernetes/                 base manifests and dev/stage/prod/openshift overlays
├── logging/                    Fluent Bit, Elasticsearch, Kibana
├── observability/              Prometheus, Grafana, Alertmanager, kube-state-metrics, alert sink
├── scripts/                    validation, quality gate, Dependency-Track gate
├── terraform/                  aws-networking and aws-compute
├── tests/                      alert rule tests and script tests
├── tools/                      local SonarQube + Dependency-Track (Docker Compose)
├── .github/                    GitHub Actions workflows and Dependabot
└── README.md
```

## Implementation Roadmap

### Completed or configured

- [x] FastAPI payment API and automated API tests
- [x] Docker containerization and non-root runtime hardening
- [x] Trivy image scanning and security finding investigation
- [x] Kubernetes Deployment, Service, health/readiness probes, and resource controls
- [x] Prometheus application metrics and Kustomize base
- [x] GitHub Actions workflows for application CI, Kubernetes security, secret scanning, dependency review, dependency audit/SBOM, and documentation validation
- [x] CycloneDX SBOM generation and Python dependency audit workflow
- [x] Prometheus/Grafana configuration, dashboard definition, and alert rules
- [x] Jenkins pipeline configuration and successful execution verified
- [x] Tekton pipeline implemented and verified with a successful PipelineRun (Ruff and the test suite passed)
- [x] Argo CD application configuration files added to the repository
- [x] Two incident runbooks documented

Jenkins execution was previously verified successfully. The Tekton PipelineRun completed successfully, with linting and the full test suite passing. Argo CD synchronization and monitoring deployment have been verified in the running cluster.

### Remaining work

- [ ] Integrate the verified Jenkins pipeline into the delivery path
- [ ] Integrate Tekton into the broader delivery path
- [ ] Run self-hosted SonarQube and Dependency-Track (`tools/`), execute the secure Tekton pipeline, and keep dated evidence
- [x] Verify Argo CD synchronization against a live cluster (latest reported check: both Applications `Synced` and `Healthy`; retain dated evidence in the repository)
- [x] Deploy Prometheus/Grafana/Alertmanager on Kind and verify pod/application health
- [ ] Verify an alert firing through Alertmanager to the in-cluster `alert-sink` receiver (`kubectl -n monitoring logs deploy/alert-sink`)
- [ ] Deploy to OpenShift (`docs/operations/openshift-deployment.md`) and keep the `oc` evidence
- [x] Configure and validate Terraform networking and compute modules in CI
- [ ] Apply AWS infrastructure only in an explicitly approved account/environment and retain plan/apply evidence
- [x] Add audit/hardening playbooks and CI syntax/lint checks
- [ ] Verify hardening against a disposable target host
- [ ] Deploy and verify centralized logging (`logging/`)
- [ ] Expand incident runbooks and operational automation
- [ ] Add final architecture, validation evidence, and interview documentation

## Engineering Principles

```text
Plan
 |
 v
Code
 |
 v
Test
 |
 v
Secure
 |
 v
Package
 |
 v
Deploy
 |
 v
Observe
 |
 v
Troubleshoot
 |
 v
Improve
```

The objective is not to list DevOps tools. It is to demonstrate how those tools are used to build, secure, deploy, observe, troubleshoot, and improve a production-oriented platform.

## Project Status

### Active development

The repository is intentionally implemented in verifiable stages. Documentation is updated as capabilities move from planned to tested implementation.

## Author

### Gaurav Singh Ghodage

DevOps / DevSecOps Engineering Portfolio Project

## Verification & Evidence Logs

- **Secure CI/CD & SCA Gate (`dtrack_gate.py`)**: [`docs/evidence/dtrack-gate-run.txt`](docs/evidence/dtrack-gate-run.txt)
- **Observability Alert Routing Drill**: [`docs/evidence/alert-routing-drill.txt`](docs/evidence/alert-routing-drill.txt)
- **Ansible Hardening Validation**: Verified via `ansible-playbook` syntax and role validation (`ansible/playbooks/hardening.yml`)
