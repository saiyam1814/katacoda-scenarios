#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-03-runtime-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl --request-timeout=3s -n book-cks-readonly get deployment web -o json > "$STATE_DIR/http-deployment.json"
python3 - "$STATE_DIR/http-deployment.json" <<'PYHTTP'
import json,sys
try:
 d=json.load(open(sys.argv[1]));s=d['spec']['template']['spec'];p=s.get('securityContext',{})
 assert d['spec'].get('replicas',1)==1 and len(s['containers'])==1, 'Keep one HTTP container and one replica'
 c=s['containers'][0];q=c.get('securityContext',{})
 assert c['image']=='busybox:1.37.0' and c['command']==['httpd','-f','-p','8080','-h','/etc'], 'Preserve the HTTP application'
 assert q.get('runAsNonRoot',p.get('runAsNonRoot')) is True, 'Require non-root execution'
 assert q.get('runAsUser',p.get('runAsUser'))==1000 and q.get('runAsGroup',p.get('runAsGroup'))==1000, 'Use UID/GID1000'
 assert q.get('seccompProfile',p.get('seccompProfile',{})).get('type')=='RuntimeDefault', 'Require RuntimeDefault seccomp on the HTTP workload'
 assert q.get('allowPrivilegeEscalation') is False and not q.get('privileged',False), 'Disable privilege escalation and privileged mode'
 assert q.get('readOnlyRootFilesystem') is True, 'Set a read-only root filesystem'
 assert set(q.get('capabilities',{}).get('drop',[]))=={'ALL'} and not q.get('capabilities',{}).get('add'), 'Drop all capabilities without adding any'
 mounts=c.get('volumeMounts',[]);volumes={v['name']:v for v in s.get('volumes',[])}
 writable=[m for m in mounts if not m.get('readOnly',False)]
 assert len(writable)==1 and writable[0]['mountPath']=='/tmp' and 'emptyDir' in volumes[writable[0]['name']], 'Only /tmp may be a writable scratch mount'
 assert not c.get('volumeDevices'), 'Do not add a raw writable block device'
 status=d.get('status',{});assert status.get('observedGeneration',0)>=d['metadata']['generation'] and status.get('updatedReplicas')==1 and status.get('availableReplicas')==1, 'Wait for the hardened HTTP rollout'
except (AssertionError,KeyError,TypeError,ValueError) as error:
 sys.exit('FAIL: HTTP workload hardening is incomplete: '+str(error))
PYHTTP
pod=$(one_ready_pod book-cks-readonly app=web)
kubectl -n book-cks-readonly exec "$pod" -- cat /proc/1/status | python3 -c 'import sys; d=dict(x.split(":",1) for x in sys.stdin if ":" in x); assert d["Uid"].split()==["1000"]*4 and d["Gid"].split()==["1000"]*4 and d["NoNewPrivs"].strip()=="1" and d["Seccomp"].strip()=="2" and int(d["CapEff"],16)==0 and int(d["CapBnd"],16)==0, "Verify the HTTP process identity and effective protections"'
kubectl -n book-cks-readonly exec "$pod" -- sh -c 'wget -T 2 -qO- http://web:8080/hostname | grep . && echo writable >/tmp/test && test "$(cat /tmp/test)" = writable'
kubectl -n book-cks-readonly exec "$pod" -- cat /proc/mounts | python3 -c 'import sys; assert any(x.split()[1]=="/" and "ro" in x.split()[3].split(",") for x in sys.stdin)'
if kubectl -n book-cks-readonly exec "$pod" -- touch /etc/book-denied >"$STATE_DIR/http-root-write" 2>&1; then fail 'Root must be read-only'; fi
grep -qi 'read-only file system' "$STATE_DIR/http-root-write" || fail 'Expected an actual read-only-filesystem denial under /etc'
pass "Step 2: Keep an HTTP server working with a read-only root"
