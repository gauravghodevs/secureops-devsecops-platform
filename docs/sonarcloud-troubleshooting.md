# SonarCloud GitHub Actions Troubleshooting

## Observed failure

The Payment API CI workflow previously failed during SonarCloud scanner
initialization with the error:

`Not authorized or organization not found`

The scanner failed while loading the server plugin index, before analysis
completed.

## Configuration

The project configuration is located at
`applications/payment-api/sonar-project.properties`.

Relevant properties:

- `sonar.organization`: SonarCloud organization key
- `sonar.projectKey`: SonarCloud project key
- `sonar.sources`: Source directory
- `sonar.tests`: Test directory

Confirm the organization and project keys against the SonarCloud project
settings.

## Troubleshooting checklist

1. Confirm the GitHub Actions repository secret `SONAR_TOKEN` exists.
2. Verify it contains the intended, valid SonarCloud token.
3. Never print the token in workflow logs or commit it to the repository.
4. Verify the token identity has permission to access the organization
   and execute analysis on the project.
5. Check `projectBaseDir` and scanner configuration.
6. Inspect the SonarCloud scanner logs after rerunning the workflow.
7. Confirm the analysis and Quality Gate result before merging.

## Important distinction

A successful Gitleaks secret scan does not confirm that SonarCloud
authentication works. These are separate CI checks.

## Resolution and current status

The workflow was updated to pass the GitHub Actions `GITHUB_TOKEN`
alongside `SONAR_TOKEN` and explicitly provide the SonarCloud organization
and project keys as scanner arguments.

The scanner also uses `-Dsonar.qualitygate.wait=true` to wait for the
Quality Gate result.

The latest previously observed Payment API CI run succeeded. Verify the
latest run and the analysis result in SonarCloud before merging.

The individual contribution of each configuration change has not been
isolated, so the original failure should not be attributed to a single
cause without further evidence.

Keep `SONAR_TOKEN` in GitHub Actions secrets. Never print it in logs
or commit it to the repository.
