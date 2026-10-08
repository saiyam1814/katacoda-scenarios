#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-10-probes-configuration
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cka-probes get pod unready -o json | json_assert 'd["status"]["phase"]=="Running" and any(c["type"]=="Ready" and c["status"]=="False" for c in d["status"]["conditions"]) and d["spec"]["containers"][0]["readinessProbe"]["httpGet"]["path"]=="/missing"' 'Require a running container failing the deliberate readiness probe'
kubectl -n book-cka-probes get endpointslices -l kubernetes.io/service-name=unready -o json | json_assert 'len([e for s in d["items"] for e in s.get("endpoints",[])])>0 and not any(e.get("conditions",{}).get("ready") for s in d["items"] for e in s.get("endpoints",[]))' 'Unready endpoint must not receive ordinary Service traffic'
pass "Step 4: Prove failed readiness excludes an endpoint"
