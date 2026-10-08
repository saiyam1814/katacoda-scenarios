#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-05-image-admission
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
kubectl -n book-cks-images get pod debug-target -o json | python3 -c 'import json,sys; d=json.load(sys.stdin); assert any(c["type"]=="Ready" and c["status"]=="True" for c in d["status"]["conditions"])'
python3 - "$STATE_DIR/pause-image" <<'PYVERIFY'
import json,subprocess,sys,copy
base=json.loads(subprocess.check_output(['kubectl','-n','book-cks-images','get','pod','debug-target','-o','json']))
for image,allowed in [(open(sys.argv[1]).read().strip(),True),('busybox:1.37.0',False)]:
 obj=copy.deepcopy(base);obj['spec']['ephemeralContainers']=[{'name':'probe','image':image,'targetContainerName':'debug-target'}]
 p=subprocess.run(['kubectl','replace','--raw','/api/v1/namespaces/book-cks-images/pods/debug-target/ephemeralcontainers?dryRun=All','-f','-'],input=json.dumps(obj),text=True,capture_output=True)
 assert (p.returncode==0)==allowed,p.stderr
 if not allowed: assert 'book-images' in p.stderr,p.stderr
PYVERIFY
test -s "$WORK_DIR/cks28-policy.yaml"
pass "Step 2: Close the ephemeral-container admission gap"
