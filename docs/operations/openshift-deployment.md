# OpenShift Deployment

This runbook deploys `payment-api` to OpenShift using `kubernetes/overlays/openshift` and records
evidence that the workload runs under OpenShift's default security constraints.

## Choose a cluster

| Option | Cost | Notes |
|---|---|---|
| Red Hat Developer Sandbox | Free, time-limited | Fastest. You cannot create projects or install Operators. |
| OpenShift Local (CRC) | Free | Needs about 16 GB RAM. You are cluster admin. |

## Deploy on the Developer Sandbox

The image must be pullable. If the GHCR package is private, make it public or add a pull secret.

```bash
oc login --token=<token> --server=<api-url>
oc project                                  # note the project name, for example myuser-dev
NS="$(oc project -q)"
oc kustomize kubernetes/overlays/openshift \
  | sed "s/namespace: payment-dev/namespace: ${NS}/" \
  | oc apply -f -
```

If the cluster rejects the `ServiceMonitor` (user workload monitoring is not enabled), remove that
document from the stream and re-apply. Record this in the evidence.

## Deploy on OpenShift Local (CRC)

```bash
oc new-project payment-dev
oc apply -k kubernetes/overlays/openshift
```

## Verify and record evidence

```bash
oc get pods -n "${NS:-payment-dev}"
oc get route payment-api -n "${NS:-payment-dev}"
POD="$(oc get pod -l app=payment-api -o name | head -n 1)"
oc get "$POD" -o jsonpath='{.metadata.annotations.openshift\.io/scc}{"\n"}'
oc get "$POD" -o jsonpath='{.spec.securityContext}{"\n"}{.spec.containers[0].securityContext}{"\n"}'
curl -sk "https://$(oc get route payment-api -o jsonpath='{.spec.host}')/health"
```

Expected result: pods are `Running`, the SCC annotation is `restricted-v2`, the container user ID is
in the project's assigned range (not `10001`), and `/health` returns HTTP 200. Save the command
output under `docs/evidence/` with the date.

## If the pod does not start

- `unable to validate against any security context constraint`: a manifest sets a fixed
  `runAsUser`. The base Deployment must not set one.
- `ImagePullBackOff`: the registry package is private or the tag does not exist.
- `CrashLoopBackOff` with permission errors: the image must be group-0 writable
  (`chgrp -R 0` and `chmod -R g=u` in the Dockerfile).
