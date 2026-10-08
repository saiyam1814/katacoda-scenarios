#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-02-pod-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-privileged get deployment inspector -o json | json_assert 'd["spec"]["template"]["spec"]["containers"][0]["securityContext"].get("privileged",False)==False and d["spec"]["template"]["spec"]["containers"][0]["securityContext"].get("allowPrivilegeEscalation",True)==False and d["spec"]["template"]["spec"]["containers"][0]["securityContext"].get("readOnlyRootFilesystem",False)' 'Repair the workload security settings'
kubectl -n book-cks-privileged get deployment inspector -o json | json_assert 'd["spec"]["template"]["spec"]["securityContext"].get("seccompProfile",{}).get("type")=="RuntimeDefault"' 'Configure RuntimeDefault seccomp on the controller'
pod=$(one_ready_pod book-cks-privileged app=inspector)
kubectl -n book-cks-privileged exec "$pod" -- cat /proc/1/status | python3 -c 'import sys; d=dict(x.split(":",1) for x in sys.stdin if ":" in x); assert d["Uid"].split()==["1000"]*4 and int(d["CapEff"],16)==0 and d["NoNewPrivs"].strip()=="1"'
if kubectl -n book-cks-privileged exec "$pod" -- touch /blocked 2>/dev/null; then fail 'Root filesystem must reject writes'; fi
test -s "$WORK_DIR/inspector.yaml"
pass "Step 2: Repair a privileged Deployment"
