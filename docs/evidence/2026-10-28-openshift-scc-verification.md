# OpenShift Overlay and Security Context Verification

Date: 2026-10-28

## 1. Cluster Context

The active Kubernetes context was `kind-devops`.
The OpenShift CLI (`oc`) was unavailable in the current shell.
Live OpenShift deployment and SCC enforcement were not verified in this session.

## 2. Kustomize Overlay Validation

Command:
`kubectl kustomize kubernetes/overlays/openshift > /tmp/openshift-rendered.yaml`

Result: PASS. The rendered manifest contained 207 lines.

Verified resource kinds:

- Deployment
- HorizontalPodAutoscaler
- NetworkPolicy
- PodDisruptionBudget
- Route
- Service
- ServiceAccount
- ServiceMonitor

## 3. Rendered Payment API Security Settings

The rendered Deployment includes:

- `allowPrivilegeEscalation: false`
- `capabilities.drop: ALL`
- `readOnlyRootFilesystem: true`
- `runAsNonRoot: true`
- Container `seccompProfile: RuntimeDefault`
- Pod `seccompProfile: RuntimeDefault`

The Deployment also mounts an `emptyDir` volume at `/tmp`.

## 4. Arbitrary UID Runtime Test

The supplied test output reports:

- Image: `ghcr.io/gauravghodevs/secureops-payment-api:8a9965cfabef1ce7ed49787141a806179be44b1b`
- Runtime identity: `uid=1000700000 gid=0(root) groups=0(root)`
- Pod reached Ready state.
- Test pod was deleted after the test.

Verification limitations:

- The current Kubernetes context is `kind-devops`.
- The test pod is no longer present.
- The supplied output has not been independently reproduced in this session.
- This result does not establish that OpenShift assigned the UID or enforced the `restricted-v2` SCC.

## 5. SCC Verification Status

Status: PENDING live OpenShift verification.

Verify the pod on an actual OpenShift cluster and confirm its assigned SCC before claiming `restricted-v2` enforcement.
