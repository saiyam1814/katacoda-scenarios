#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-02-pod-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl get ns book-cks-psa -o json | json_assert 'd["metadata"]["labels"].get("pod-security.kubernetes.io/enforce") == "restricted" and d["metadata"]["labels"].get("pod-security.kubernetes.io/enforce-version") == "v1.35"' 'Pin restricted enforcement to v1.35'
kubectl -n book-cks-psa get pod worker -o json | python3 -c 'import json,sys; p=json.load(sys.stdin)["spec"]; assert len(p["containers"])==1; c=p["containers"][0]; s=p.get("securityContext",{}); q=c.get("securityContext",{}); assert c["image"]=="busybox:1.37.0" and c["command"]==["sh","-c","sleep 3600"]; assert q.get("runAsNonRoot",s.get("runAsNonRoot")) is True and q.get("runAsUser",s.get("runAsUser"))==1000; assert q.get("seccompProfile",s.get("seccompProfile",{})).get("type")=="RuntimeDefault"; assert q.get("allowPrivilegeEscalation") is False and "ALL" in q.get("capabilities",{}).get("drop",[])'
ready_pod book-cks-psa worker
kubectl -n book-cks-psa exec worker -- id -u | python3 -c 'import sys; assert sys.stdin.read().strip()=="1000", "Worker UID must be 1000"'
python3 - <<'PYPROBE'
import copy,json,subprocess
base={"apiVersion":"v1","kind":"Pod","metadata":{"name":"admission-probe","namespace":"book-cks-psa"},"spec":{"securityContext":{"runAsNonRoot":True,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}},"containers":[{"name":"test","image":"busybox:1.37.0","command":["sleep","3600"],"securityContext":{"allowPrivilegeEscalation":False,"capabilities":{"drop":["ALL"]}}}]}}
def check(obj,allowed):
    p=subprocess.run(['kubectl','create','--dry-run=server','-f','-'],input=json.dumps(obj),text=True,capture_output=True)
    assert (p.returncode==0)==allowed, p.stderr or p.stdout
    if not allowed: assert 'violates PodSecurity' in p.stderr, 'Rejection was not caused by Pod Security: '+p.stderr
check(base,True)
priv=copy.deepcopy(base);priv['spec']['containers'][0]['securityContext']['privileged']=True;priv['spec']['containers'][0]['securityContext']['allowPrivilegeEscalation']=True;check(priv,False)
host=copy.deepcopy(base);host['spec']['hostNetwork']=True;check(host,False)
PYPROBE
pass "All checks passed for cks-02-pod-security"
