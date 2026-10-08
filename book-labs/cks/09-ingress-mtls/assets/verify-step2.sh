#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-09-ingress-mtls
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-mesh get peerauthentication strict -o json | json_assert 'd["spec"]["mtls"]["mode"]=="STRICT" and not d["spec"].get("selector")' 'Require STRICT mTLS for the protected server'
python3 - <<'PYVERIFY'
from concurrent.futures import ThreadPoolExecutor
import subprocess
def probe(ns,pod,url):
 return subprocess.run(['kubectl','-n',ns,'exec',pod,'-c',pod,'--','curl','--max-time','2','-sS','-o','/dev/null','-w','%{http_code}',url],capture_output=True,text=True,timeout=4)
with ThreadPoolExecutor(max_workers=4) as pool:
 calls=[pool.submit(probe,*x) for x in [('book-cks-mesh','caller','http://secure/'),('book-cks-mesh','other','http://secure/'),('book-cks-plain','plain','http://secure.book-cks-mesh.svc.cluster.local/'),('book-cks-plain','plain','http://web.book-cks-ingress.svc.cluster.local/')]]
 good,bad,plain,control=[x.result() for x in calls]
assert good.returncode==0 and good.stdout=='200',(good.stdout,good.stderr)
assert bad.returncode==0 and bad.stdout=='403',(bad.stdout,bad.stderr)
assert plain.returncode!=0 and plain.stdout=='000',(plain.stdout,plain.stderr)
assert control.returncode==0 and control.stdout=='200','Plaintext client must still reach an unmeshed control service'
PYVERIFY
istioctl proxy-config clusters caller -n book-cks-mesh --fqdn secure.book-cks-mesh.svc.cluster.local -o json | grep -q envoy.transport_sockets.tls
grep -q envoy.transport_sockets.tls "$WORK_DIR/mesh-clusters.json"
python3 - "$WORK_DIR/mesh-certificates.json" <<'PYVERIFY'
import json,sys
d=json.load(open(sys.argv[1]));assert d.get('dynamicActiveSecrets'), 'Retain actually issued proxy certificates'
PYVERIFY
pass "Step 2: Require mTLS and authorize a service identity"
