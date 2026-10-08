#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-02-pod-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-privileged get deployment inspector -o json | json_assert 'd["spec"]["template"]["spec"]["containers"][0]["securityContext"].get("privileged",False)==False and d["spec"]["template"]["spec"]["containers"][0]["securityContext"].get("allowPrivilegeEscalation",True)==False and d["spec"]["template"]["spec"]["containers"][0]["securityContext"].get("readOnlyRootFilesystem",False)' 'Repair the workload security settings'
kubectl -n book-cks-privileged get deployment inspector -o json | json_assert 'd["spec"]["template"]["spec"]["securityContext"].get("seccompProfile",{}).get("type")=="RuntimeDefault"' 'Configure RuntimeDefault seccomp on the controller'
kubectl -n book-cks-privileged get deployment inspector -o json | json_assert 'len(d["spec"]["template"]["spec"]["containers"])==1 and set(d["spec"]["template"]["spec"]["containers"][0]["securityContext"].get("capabilities",{}).get("drop",[]))=={"ALL"} and not d["spec"]["template"]["spec"]["containers"][0]["securityContext"].get("capabilities",{}).get("add")' 'Drop every capability in the controller without adding any back'
pod=$(one_ready_pod book-cks-privileged app=inspector)
kubectl -n book-cks-privileged exec "$pod" -- cat /proc/1/status | python3 -c 'import sys; d=dict(x.split(":",1) for x in sys.stdin if ":" in x); assert d["Uid"].split()==["1000"]*4 and d["Gid"].split()==["1000"]*4 and int(d["CapEff"],16)==0 and int(d["CapBnd"],16)==0 and d["NoNewPrivs"].strip()=="1"'
kubectl -n book-cks-privileged exec "$pod" -- cat /proc/mounts | python3 -c 'import sys; assert any(x.split()[1]=="/" and "ro" in x.split()[3].split(",") for x in sys.stdin), "The actual root mount must be read-only"'
if kubectl -n book-cks-privileged exec "$pod" -- touch /etc/book-denied >"$STATE_DIR/privileged-root-write" 2>&1; then fail 'Root filesystem must reject writes'; fi
grep -qi 'read-only file system' "$STATE_DIR/privileged-root-write" || fail 'Require read-only filesystem enforcement rather than only an ownership denial'
test -s "$WORK_DIR/inspector.yaml"
pass "Step 2: Repair a privileged Deployment"
