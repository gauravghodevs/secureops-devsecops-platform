#!/usr/bin/env python3
"""Upload a CycloneDX SBOM to Dependency-Track and gate on vulnerability counts.

Stdlib only, so it runs in any CI image (Tekton task, Jenkins agent, laptop).

Environment:
  DT_URL      base URL of the Dependency-Track API server, e.g. http://192.168.1.50:8081
  DT_API_KEY  API key of a team with BOM_UPLOAD, PROJECT_CREATION_UPLOAD and VIEW_PORTFOLIO

Exit codes: 0 = gate passed, 1 = gate failed (policy), 2 = error talking to Dependency-Track.
"""
import argparse
import base64
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request


class DTrackError(RuntimeError):
    pass


def evaluate(metrics: dict, max_critical: int, max_high: int) -> list[str]:
    """Return a list of policy violations (empty list == pass). A limit < 0 disables it."""
    violations = []
    for severity, limit in (("critical", max_critical), ("high", max_high)):
        found = int(metrics.get(severity, 0) or 0)
        if limit >= 0 and found > limit:
            violations.append(f"{severity}: found {found}, allowed {limit}")
    return violations


class Client:
    def __init__(self, base_url: str, api_key: str, timeout: int = 30):
        self.base = base_url.rstrip("/")
        self.key = api_key
        self.timeout = timeout

    def request(self, method: str, path: str, body: dict | None = None):
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(
            f"{self.base}{path}",
            data=data,
            method=method,
            headers={"X-Api-Key": self.key, "Content-Type": "application/json"},
        )
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:  # noqa: S310
                raw = resp.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as exc:
            raise DTrackError(f"{method} {path} -> HTTP {exc.code}: {exc.read()[:200]!r}") from exc
        except urllib.error.URLError as exc:
            raise DTrackError(f"{method} {path} -> {exc.reason}") from exc

    def upload_bom(self, name: str, version: str, bom_path: str) -> str:
        with open(bom_path, "rb") as fh:
            bom_b64 = base64.b64encode(fh.read()).decode()
        payload = {"projectName": name, "projectVersion": version, "autoCreate": True, "bom": bom_b64}
        return self.request("PUT", "/api/v1/bom", payload)["token"]

    def wait_for_processing(self, token: str, timeout: int) -> None:
        deadline = time.monotonic() + timeout
        # /event/token is the current endpoint; /bom/token is the older one.
        paths = [f"/api/v1/event/token/{token}", f"/api/v1/bom/token/{token}"]
        while time.monotonic() < deadline:
            for path in paths:
                try:
                    if not self.request("GET", path).get("processing", False):
                        return
                    break
                except DTrackError as exc:
                    if "HTTP 404" not in str(exc):
                        raise
            time.sleep(5)
        raise DTrackError(f"timed out after {timeout}s waiting for BOM processing")

    def project_uuid(self, name: str, version: str) -> str:
        query = urllib.parse.urlencode({"name": name, "version": version})
        return self.request("GET", f"/api/v1/project/lookup?{query}")["uuid"]

    def current_metrics(self, project_uuid: str) -> dict:
        # Ask Dependency-Track to recompute, then read. Metrics are updated asynchronously.
        self.request("GET", f"/api/v1/metrics/project/{project_uuid}/refresh")
        time.sleep(10)
        return self.request("GET", f"/api/v1/metrics/project/{project_uuid}/current")


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--bom", required=True, help="path to CycloneDX JSON SBOM")
    p.add_argument("--project", required=True)
    p.add_argument("--version", required=True)
    p.add_argument("--max-critical", type=int, default=0, help="-1 disables")
    p.add_argument("--max-high", type=int, default=-1, help="-1 disables (default)")
    p.add_argument("--timeout", type=int, default=300)
    args = p.parse_args(argv)

    url, key = os.environ.get("DT_URL"), os.environ.get("DT_API_KEY")
    if not url or not key:
        print("DT_URL and DT_API_KEY must be set", file=sys.stderr)
        return 2

    try:
        client = Client(url, key)
        token = client.upload_bom(args.project, args.version, args.bom)
        print(f"BOM uploaded, token={token}; waiting for analysis...")
        client.wait_for_processing(token, args.timeout)
        metrics = client.current_metrics(client.project_uuid(args.project, args.version))
    except (DTrackError, KeyError, OSError) as exc:
        print(f"Dependency-Track error: {exc}", file=sys.stderr)
        return 2

    summary = {k: metrics.get(k, 0) for k in ("critical", "high", "medium", "low")}
    print(f"Findings for {args.project}:{args.version} -> {summary}")
    violations = evaluate(metrics, args.max_critical, args.max_high)
    if violations:
        print("SCA GATE FAILED:\n  " + "\n  ".join(violations), file=sys.stderr)
        return 1
    print("SCA gate passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
