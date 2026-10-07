#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
ready_deploy book-cks-runtime worker
kubectl -n book-cks-runtime get deploy worker -o json | python3 -c 'import json,sys; d=json.load(sys.stdin); s=d["spec"]["template"]["spec"]; c=s["containers"]; assert d["spec"]["replicas"]==1 and len(c)==1; c=c[0]; p=s["securityContext"]; q=c["securityContext"]; assert p["runAsUser"]==1000 and p["runAsGroup"]==1000 and p["runAsNonRoot"] is True and p["fsGroup"]==1000 and p["seccompProfile"]["type"]=="RuntimeDefault"; assert q["allowPrivilegeEscalation"] is False and q["readOnlyRootFilesystem"] is True and not q.get("privileged",False) and set(q["capabilities"]["drop"])=={"ALL"} and not q["capabilities"].get("add"); assert c["image"]=="busybox:1.37.0" and c["command"]==["sh","-c","sleep 3600"]; assert any(m["mountPath"]=="/tmp" and any(v["name"]==m["name"] and "emptyDir" in v for v in s["volumes"]) for m in c["volumeMounts"])'
pod=$(one_ready_pod book-cks-runtime app=worker)
kubectl -n book-cks-runtime exec "$pod" -- cat /proc/1/status | python3 -c 'import sys; fields=dict(line.split(":",1) for line in sys.stdin if ":" in line); assert fields["Uid"].split()==["1000"]*4; assert fields["Gid"].split()==["1000"]*4; assert fields["NoNewPrivs"].strip()=="1"; assert fields["Seccomp"].strip()=="2"; assert int(fields["CapEff"].strip(),16)==0'
kubectl -n book-cks-runtime exec "$pod" -- cat /proc/mounts | python3 -c 'import sys; mounts=[line.split() for line in sys.stdin]; assert any(m[1]=="/" and "ro" in m[3].split(",") for m in mounts), "Root mount must be read-only"'
kubectl -n book-cks-runtime exec "$pod" -- sh -c 'printf test > /tmp/writable && test "$(cat /tmp/writable)" = test && rm /tmp/writable'
if kubectl -n book-cks-runtime exec "$pod" -- touch /root-write-test >"$STATE_DIR/root-write" 2>&1; then fail 'Root filesystem unexpectedly writable'; fi
pass "All checks passed for cks-03-runtime-hardening"
