#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cka-03-kustomize
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
assert_deploy_ready book-cka-kustomize prod-web
kubectl -n book-cka-kustomize get deployment prod-web -o json | json_assert 'd["spec"]["replicas"]==3 and d["spec"]["template"]["spec"]["containers"][0]["image"]=="nginx:1.28.0" and d["spec"]["selector"]["matchLabels"].get("environment")=="production"' 'Require the requested production overlay'
test -s "$WORK_DIR/app/rendered.yaml" || fail 'Save the rendered application manifest'
python3 - "$WORK_DIR/app/base" "$STATE_DIR/base-hashes.json" <<'PYHASH'
import hashlib,json,pathlib,sys
p=pathlib.Path(sys.argv[1]);expected=json.loads(pathlib.Path(sys.argv[2]).read_text());assert expected=={f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in p.iterdir() if f.is_file()}, 'Do not edit the shared base'
PYHASH
kubectl create --dry-run=client -f "$WORK_DIR/app/rendered.yaml" -o json > "$STATE_DIR/rendered-objects.json"
python3 - "$STATE_DIR/rendered-objects.json" <<'PYRENDER'
import json,pathlib,sys
text=pathlib.Path(sys.argv[1]).read_text().strip();decoder=json.JSONDecoder();objects=[]
while text:
 obj,end=decoder.raw_decode(text);objects.extend(obj['items'] if obj.get('kind')=='List' else [obj]);text=text[end:].strip()
assert any(o['kind']=='Deployment' and o['metadata']['name']=='prod-web' and o['spec']['replicas']==3 and o['spec']['template']['spec']['containers'][0]['image']=='nginx:1.28.0' for o in objects), 'Saved render must contain the overlay Deployment'
assert any(o['kind']=='Service' and o['metadata']['name']=='prod-web' for o in objects), 'Saved render must contain the overlay Service'
PYRENDER

kubectl -n book-cka-kustomize exec client -- wget -qO- -T 3 http://prod-web | grep -q 'Welcome to nginx' || fail 'The rendered Service must reach the application'
pass "Step 1: Render and apply an application overlay"
