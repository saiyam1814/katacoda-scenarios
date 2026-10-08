#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-01-rbac
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_pod_ready book-cka-rbac web-identity
kubectl -n book-cka-rbac get pod web-identity -o json | json_assert 'd["spec"]["serviceAccountName"]=="demo-sa" and d["spec"].get("automountServiceAccountToken") is False and d["spec"]["containers"][0]["image"]=="nginx:1.28.0" and not any("serviceAccountToken" in s for v in d["spec"].get("volumes",[]) for s in v.get("projected",{}).get("sources",[]))' 'Use the requested account and disable token projection'
kubectl -n book-cka-rbac exec web-identity -- test ! -e /var/run/secrets/kubernetes.io/serviceaccount/token
pass "Step 3: Run a Pod without an API token"
