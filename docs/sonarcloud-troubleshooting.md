# SonarCloud GitHub Actions Troubleshooting

## Observed failure

The Payment API CI workflow fails during SonarCloud scanner initialization
with the following error:

`Not authorized or organization not found`

The scanner fails while loading the server plugin index, before analysis
completes.

## Configuration

The project configuration is located at
`applications/payment-api/sonar-project.properties`.

Expected properties:

- `sonar.organization`: SonarCloud organization key
- `sonar.projectKey`: SonarCloud project key
- `sonar.sources`: Source directory
- `sonar.tests`: Test directory

Confirm organization and project keys against the SonarCloud project settings.

## Troubleshooting checklist

1. Confirm the GitHub Actions repository secret `SONAR_TOKEN` exists.
2. Confirm the secret contains the intended, currently valid SonarCloud token.
3. Never print the token in workflow logs or commit it to the repository.
4. Verify the token's identity has permission to access the organization and
   execute analysis on the project.
5. Check the workflow's `projectBaseDir` and scanner configuration.
6. Rerun the Payment API CI workflow and inspect the SonarCloud scanner logs.
7. Confirm analysis completes and the Quality Gate passes before merging.

## Important distinction

A successful Gitleaks secret scan does not confirm that SonarCloud
authentication works. These are separate checks in the CI pipeline.

A previous successful SonarCloud analysis also does not prove that the
current GitHub Actions token and permissions are correct.

## Current status

The scanner has reported an authorization or organization-access error.
The exact root cause remains unconfirmed until the token, permissions,
and organization access have been verified.
EOFmkdir -p docs

cat > docs/sonarcloud-troubleshooting.md <<'EOF'
# SonarCloud GitHub Actions Troubleshooting

## Observed failure

The Payment API CI workflow fails during SonarCloud scanner initialization
with the following error:

`Not authorized or organization not found`

The scanner fails while loading the server plugin index, before analysis
completes.

## Configuration

The project configuration is located at
`applications/payment-api/sonar-project.properties`.

Expected properties:

- `sonar.organization`: SonarCloud organization key
- `sonar.projectKey`: SonarCloud project key
- `sonar.sources`: Source directory
- `sonar.tests`: Test directory

Confirm organization and project keys against the SonarCloud project settings.

## Troubleshooting checklist

1. Confirm the GitHub Actions repository secret `SONAR_TOKEN` exists.
2. Confirm the secret contains the intended, currently valid SonarCloud token.
3. Never print the token in workflow logs or commit it to the repository.
4. Verify the token's identity has permission to access the organization and
   execute analysis on the project.
5. Check the workflow's `projectBaseDir` and scanner configuration.
6. Rerun the Payment API CI workflow and inspect the SonarCloud scanner logs.
7. Confirm analysis completes and the Quality Gate passes before merging.

## Important distinction

A successful Gitleaks secret scan does not confirm that SonarCloud
authentication works. These are separate checks in the CI pipeline.

A previous successful SonarCloud analysis also does not prove that the
current GitHub Actions token and permissions are correct.

## Current status

The scanner has reported an authorization or organization-access error.
The exact root cause remains unconfirmed until the token, permissions,
and organization access have been verified.
