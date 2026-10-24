#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_MANIFEST="$(mktemp)"

cleanup() {
    rm -f "$TEMP_MANIFEST"
}
trap cleanup EXIT

log() {
    printf '\n[%s] %s\n' "$1" "$2"
}

fail() {
    printf 'ERROR: %s\n' "$1" >&2
    exit 1
}

log INFO "SecureOps repository validation started"

for tool in bash kubectl; do
    command -v "$tool" >/dev/null 2>&1 ||
        fail "Required command not found: $tool"
done

log CHECK "Checking Bash syntax"
mapfile -t SHELL_SCRIPTS < <(
    find "$REPO_ROOT/scripts" -type f -name '*.sh' -print | sort
)

((${#SHELL_SCRIPTS[@]} > 0)) ||
    fail "No shell scripts found under scripts/"

for script in "${SHELL_SCRIPTS[@]}"; do
    bash -n "$script"
    printf 'PASS: %s\n' "${script#"$REPO_ROOT"/}"
done

if command -v shellcheck >/dev/null 2>&1; then
    log CHECK "Running ShellCheck"
    shellcheck "${SHELL_SCRIPTS[@]}"
else
    log WARN "ShellCheck not installed; static shell analysis skipped"
fi

log CHECK "Running Payment API tests and lint"
"$REPO_ROOT/scripts/quality-gate.sh"

log CHECK "Rendering Kubernetes base manifests & security primitives"
kubectl kustomize "$REPO_ROOT/kubernetes/base" > "$TEMP_MANIFEST"

for kind in Deployment Service ServiceAccount NetworkPolicy PodDisruptionBudget HorizontalPodAutoscaler; do
    grep -q "^kind: ${kind}$" "$TEMP_MANIFEST" ||
        fail "Rendered base manifests do not contain a ${kind}"
done

grep -q 'name: payment-api' "$TEMP_MANIFEST" ||
    fail "Rendered manifests do not contain payment-api"

log CHECK "Rendering Kubernetes environment overlays (dev, stage, prod, openshift)"
for overlay in dev stage prod openshift; do
    kubectl kustomize "$REPO_ROOT/kubernetes/overlays/${overlay}" > "$TEMP_MANIFEST"
    grep -q '^kind: Deployment$' "$TEMP_MANIFEST" ||
        fail "Overlay ${overlay} failed to render Deployment"
    printf 'PASS: kubernetes/overlays/%s\n' "$overlay"
done

log PASS "Kubernetes manifests and all overlays rendered and verified"
log PASS "SecureOps repository validation completed successfully"
