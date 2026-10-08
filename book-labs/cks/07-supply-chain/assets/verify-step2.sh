#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
pod=$(one_ready_pod book-cks-supply app=web)
kubectl -n book-cks-supply get deploy web -o json | json_assert 'd["spec"]["template"]["spec"]["containers"][0]["image"]=="localhost/book-cks-web:v1" and d["spec"]["template"]["spec"]["containers"][0]["imagePullPolicy"]=="Never"' 'Use the locally built image'
kubectl -n book-cks-supply exec "$pod" -- sh -c 'test "$(id -u)" = 1000 && wget -T 2 -qO- http://web:8080/ | grep -q book-secure-web && test ! -e /site/developer-secret.txt && test -z "${APP_TOKEN:-}"'
kubectl -n book-cks-supply get deploy web -o json | python3 -c 'import json,sys; d=json.load(sys.stdin); s=d["spec"]["template"]["spec"]; assert len(s["containers"])==1; q=s["containers"][0].get("securityContext",{}); assert q.get("readOnlyRootFilesystem") is True and q.get("allowPrivilegeEscalation") is False and not q.get("privileged",False); assert set(q.get("capabilities",{}).get("drop",[]))=={"ALL"} and not q.get("capabilities",{}).get("add"), "Harden the built HTTP workload"'
kubectl -n book-cks-supply exec "$pod" -- cat /proc/mounts | python3 -c 'import sys; assert any(x.split()[1]=="/" and "ro" in x.split()[3].split(",") for x in sys.stdin), "Root mount must actually be read-only"'
kubectl -n book-cks-supply exec "$pod" -- cat /proc/1/status | python3 -c 'import sys; d=dict(x.split(":",1) for x in sys.stdin if ":" in x); assert d["NoNewPrivs"].strip()=="1" and int(d["CapEff"],16)==0 and int(d["CapBnd"],16)==0, "Verify the actual application privilege restrictions"'
if kubectl -n book-cks-supply exec "$pod" -- touch /etc/book-denied >"$STATE_DIR/built-root-write" 2>&1; then fail 'The built workload root must be read-only'; fi
grep -qi 'read-only file system' "$STATE_DIR/built-root-write" || fail 'Write denial must come from a read-only root, not UID1000 ownership permissions'
buildah --storage-driver=vfs inspect localhost/book-cks-web:v1 | python3 -c 'import json,sys; d=json.load(sys.stdin); c=d["Docker"]["config"]; assert c["User"]=="1000:1000" and not any(x.startswith("APP_TOKEN=") for x in c.get("Env",[]))'
grep -qx 'developer-secret.txt' "$WORK_DIR/build/.dockerignore"
pass "Step 2: Repair and build a minimal image"
