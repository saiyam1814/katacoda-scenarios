#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-seccomp get pod demo -o json | json_assert 'd["spec"]["securityContext"]["seccompProfile"]=={"type":"Localhost","localhostProfile":"profiles/book-deny-chmod.json"}' 'Select the installed Localhost profile'
python3 -c 'import json; d=json.load(open("/var/lib/kubelet/seccomp/profiles/book-deny-chmod.json")); assert d["defaultAction"]=="SCMP_ACT_ALLOW"; assert any(set(x["names"])>={"chmod","fchmod","fchmodat"} and x["action"]=="SCMP_ACT_ERRNO" and x["errnoRet"]==1 for x in d["syscalls"])'
kubectl -n book-cks-seccomp exec demo -- sh -c 'echo allowed >/tmp/allowed && test "$(cat /tmp/allowed)" = allowed && grep -q "Seccomp:[[:space:]]*2" /proc/1/status'
if kubectl -n book-cks-seccomp exec demo -- chmod 600 /tmp/allowed >"$STATE_DIR/chmod" 2>&1; then fail 'chmod must be denied by seccomp'; fi
grep -qi 'Operation not permitted' "$STATE_DIR/chmod" || fail 'Expected seccomp EPERM denial'
pass "Step 3: Install and enforce a local seccomp profile"
