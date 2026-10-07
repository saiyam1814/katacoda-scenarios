#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-06-audit-policy
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
test -f "$STATE_DIR/ready" || fail "Run setup.sh first"
cat > "$WORK_DIR/audit-policy.json" <<'JSON'
{
  "apiVersion": "audit.k8s.io/v1",
  "kind": "Policy",
  "omitStages": ["RequestReceived"],
  "rules": [
    {"level": "Metadata", "resources": [{"group": "", "resources": ["secrets"]}]},
    {"level": "None", "nonResourceURLs": ["/healthz", "/healthz/*", "/readyz", "/readyz/*", "/livez", "/livez/*"]},
    {"level": "RequestResponse", "verbs": ["create", "update", "patch", "delete"], "resources": [{"group": "apps", "resources": ["deployments"]}]},
    {"level": "Metadata"}
  ]
}
JSON
