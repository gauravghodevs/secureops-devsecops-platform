#!/usr/bin/env bash
# Create the secrets the secure Tekton pipeline reads. Values come from environment variables so
# nothing sensitive is written to disk or committed.
#
#   SONAR_HOST_URL SONAR_TOKEN   SonarQube URL (reachable from the cluster) and a token
#   DT_URL DT_API_KEY            Dependency-Track API URL and API key
set -euo pipefail

NAMESPACE="${1:-default}"
: "${SONAR_HOST_URL:?set SONAR_HOST_URL}" "${SONAR_TOKEN:?set SONAR_TOKEN}"
: "${DT_URL:?set DT_URL}" "${DT_API_KEY:?set DT_API_KEY}"

apply_secret() {
  # Render client-side and pipe to apply, so re-running updates the secret.
  kubectl create secret generic "$@" -n "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
}

apply_secret sonar-credentials \
  --from-literal=SONAR_HOST_URL="${SONAR_HOST_URL}" --from-literal=SONAR_TOKEN="${SONAR_TOKEN}"
apply_secret dtrack-credentials \
  --from-literal=DT_URL="${DT_URL}" --from-literal=DT_API_KEY="${DT_API_KEY}"

echo "Secrets created in namespace ${NAMESPACE}"
