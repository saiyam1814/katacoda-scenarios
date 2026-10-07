#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
python3 - "$WORK_DIR/base" "$STATE_DIR/base-hash" <<'PYHASH'
import hashlib,pathlib,sys
p=pathlib.Path(sys.argv[1]);assert hashlib.sha256(b''.join(x.read_bytes() for x in sorted(p.iterdir()))).hexdigest()==pathlib.Path(sys.argv[2]).read_text().strip(), 'Do not modify the base'
PYHASH
kubectl apply --dry-run=client -k "$WORK_DIR/overlays/prod" -o json | json_assert 'd["kind"] == "Deployment" and d["metadata"]["name"] == "prod-web" and d["metadata"]["namespace"] == "book-cka-kustomize" and d["spec"]["replicas"] == 3 and d["spec"]["template"]["spec"]["containers"][0]["image"] == "nginx:1.28.0" and d["metadata"]["labels"]["environment"] == "prod" and d["spec"]["template"]["metadata"]["labels"]["environment"] == "prod"' 'Overlay does not produce the requested deployment'
ready_deploy book-cka-kustomize prod-web
kubectl -n book-cka-kustomize get deployment prod-web -o json | json_assert 'd["spec"]["replicas"] == 3 and d["status"].get("availableReplicas") == 3 and d["spec"]["template"]["spec"]["containers"][0]["image"] == "nginx:1.28.0" and d["metadata"]["labels"].get("environment") == "prod" and d["spec"]["template"]["metadata"]["labels"].get("environment") == "prod"' 'Live Deployment does not match requirements' 
pass "All checks passed for cka-03-kustomize"
