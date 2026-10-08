#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
pod=$(one_ready_pod book-cks-supply app=web)
kubectl -n book-cks-supply get deploy web -o json | json_assert 'd["spec"]["template"]["spec"]["containers"][0]["image"]=="localhost/book-cks-web:v1" and d["spec"]["template"]["spec"]["containers"][0]["imagePullPolicy"]=="Never"' 'Use the locally built image'
kubectl -n book-cks-supply exec "$pod" -- sh -c 'test "$(id -u)" = 1000 && wget -T 2 -qO- http://web:8080/ | grep -q book-secure-web && test ! -e /site/developer-secret.txt && test -z "${APP_TOKEN:-}"'
if kubectl -n book-cks-supply exec "$pod" -- touch /blocked 2>/dev/null; then fail 'The built workload root must be read-only'; fi
buildah --storage-driver=vfs inspect localhost/book-cks-web:v1 | python3 -c 'import json,sys; d=json.load(sys.stdin); c=d["Docker"]["config"]; assert c["User"]=="1000:1000" and not any(x.startswith("APP_TOKEN=") for x in c.get("Env",[]))'
grep -qx 'developer-secret.txt' "$WORK_DIR/build/.dockerignore"
pass "Step 2: Repair and build a minimal image"
