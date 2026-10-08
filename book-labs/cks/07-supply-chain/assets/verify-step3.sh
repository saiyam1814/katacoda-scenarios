#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubesec scan "$WORK_DIR/repaired.yaml" > "$STATE_DIR/kubesec-current.json"
python3 - "$WORK_DIR" "$STATE_DIR" <<'PYVERIFY'
import json,sys,pathlib
w,s=map(pathlib.Path,sys.argv[1:]);b=json.load(open(w/'reports/kubesec-before.json'))[0];a=json.load(open(w/'reports/kubesec-after.json'))[0];c=json.load(open(s/'kubesec-current.json'))[0]
assert b['score']<0 and a.get('valid') is True and c.get('valid') is True and a['score']>b['score'] and a['score']==c['score'] and not c.get('scoring',{}).get('critical',[])
PYVERIFY
kubectl create --dry-run=client -f "$WORK_DIR/repaired.yaml" -o json > "$STATE_DIR/kubesec-submitted.json"
kubectl -n book-cks-supply get pod scan-target -o json > "$STATE_DIR/kubesec-live.json"
python3 - "$STATE_DIR/kubesec-submitted.json" "$STATE_DIR/kubesec-live.json" <<'PYLIVE'
import json,sys
try:
 expected,live=(json.load(open(p)) for p in sys.argv[1:])
 assert expected['kind']=='Pod' and expected['metadata']['name']=='scan-target' and expected['metadata']['namespace']=='book-cks-supply', 'Scan and apply the requested Pod'
 def subset(want,actual,path):
  if isinstance(want,dict):
   assert isinstance(actual,dict), path
   for key,value in want.items():assert key in actual,path+'.'+key;subset(value,actual[key],path+'.'+key)
  elif isinstance(want,list):
   assert isinstance(actual,list) and len(want)==len(actual),path
   for i,(left,right) in enumerate(zip(want,actual)):subset(left,right,path+'['+str(i)+']')
  else:assert want==actual,path
 # Compare submitted Pod settings to the live object while allowing API defaults.
 # A hardened scan file beside an older permissive Pod must not pass.
 for doc in (expected,live):
  s=doc['spec'];p=s.get('securityContext',{});assert len(s['containers'])==1
  q=s['containers'][0].get('securityContext',{})
  assert q.get('runAsUser',p.get('runAsUser'))==1000 and q.get('runAsNonRoot',p.get('runAsNonRoot')) is True, 'Require UID1000 and non-root execution'
  assert q.get('seccompProfile',p.get('seccompProfile',{})).get('type')=='RuntimeDefault', 'Require RuntimeDefault seccomp'
  assert not q.get('privileged',False) and q.get('allowPrivilegeEscalation') is False and q.get('readOnlyRootFilesystem') is True, 'Apply the scanned filesystem and privilege protections'
  assert set(q.get('capabilities',{}).get('drop',[]))=={'ALL'} and not q.get('capabilities',{}).get('add'), 'Apply the scanned capability drop'
 subset(expected['spec'].get('securityContext',{}),live['spec'].get('securityContext',{}),'securityContext')
 subset(expected['spec']['containers'],live['spec']['containers'],'containers')
 assert not live['metadata'].get('deletionTimestamp') and any(c['type']=='Ready' and c['status']=='True' for c in live.get('status',{}).get('conditions',[])), 'Keep the repaired Pod Ready'
except (AssertionError,KeyError,TypeError,ValueError) as error:
 sys.exit('FAIL: live Pod does not match the hardened scanned manifest: '+str(error))
PYLIVE
kubectl -n book-cks-supply exec scan-target -- cat /proc/1/status | python3 -c 'import sys; d=dict(x.split(":",1) for x in sys.stdin if ":" in x); assert d["Uid"].split()==["1000"]*4 and d["NoNewPrivs"].strip()=="1" and d["Seccomp"].strip()=="2" and int(d["CapEff"],16)==0 and int(d["CapBnd"],16)==0, "Require actual process hardening"'
kubectl -n book-cks-supply exec scan-target -- cat /proc/mounts | python3 -c 'import sys; assert any(x.split()[1]=="/" and "ro" in x.split()[3].split(",") for x in sys.stdin), "Require actual read-only root"'

pass "Step 3: Use Kubesec findings to repair a manifest"
