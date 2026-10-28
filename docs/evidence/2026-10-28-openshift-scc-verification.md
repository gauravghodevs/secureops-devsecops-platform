# OpenShift Deployment and restricted-v2 SCC Verification
Date: 2026-10-28

## 1. Current cluster context

The verified Kubernetes context was `kind-devops`.
This confirms the local Kubernetes environment, not an OpenShift cluster.

## 2. Payment API runtime identity

Command:
`kubectl exec -n default payment-api-7df874b85d-j6r9t -- id`

Observed output:
`uid=10001 gid=0(root) groups=0(root)`

## 3. Container security configuration

Observed pod/container settings:
- allowPrivilegeEscalation: false
- capabilities.drop: ALL
- readOnlyRootFilesystem: true
- runAsNonRoot: true
- seccompProfile: RuntimeDefault

## 4. OpenShift SCC enforcement status

Not verified against an OpenShift cluster in this session.
The current context is kind-devops, so these results must not be represented as proof of restricted-v2 SCC enforcement.

## 5. Follow-up

Validate the OpenShift overlay and repeat the runtime verification against an actual OpenShift cluster before claiming SCC enforcement.
