#!/usr/bin/env bash
set -euo pipefail

echo "=== Running Local CycloneDX SBOM Generation & SCA Check ==="
APP_DIR="applications/payment-api"
SBOM_FILE="sbom-cyclonedx.json"

# Generate CycloneDX SBOM using Trivy
trivy fs --format cyclonedx --output "${SBOM_FILE}" "${APP_DIR}"

# Scan the generated SBOM for HIGH or CRITICAL vulnerabilities
echo "Scanning SBOM for HIGH/CRITICAL vulnerabilities..."
trivy sbom --severity HIGH,CRITICAL --exit-code 1 "${SBOM_FILE}"

echo "SCA Quality Gate Passed: No unmitigated High/Critical vulnerabilities found."
