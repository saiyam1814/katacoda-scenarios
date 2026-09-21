#!/bin/bash
set -euo pipefail
kubectl -n team-apps get bucketapp media-assets -o json > /tmp/cnpe15-xr.json
kubectl -n team-apps get configmap media-assets -o json > /tmp/cnpe15-cm.json
python3 - <<'PY'
import json
x=json.load(open('/tmp/cnpe15-xr.json')); c=json.load(open('/tmp/cnpe15-cm.json'))
assert all(any(v['type']==t and v['status']=='True' for v in x['status']['conditions']) for t in ['Ready','Synced'])
assert x['spec']['crossplane']['compositionRef']['name']=='bucketapp-configmap'
assert c['data']=={'region':'eu-west-1','size':'small'}
assert c['metadata']['namespace']==x['metadata']['namespace']=='team-apps'
assert any(o['uid']==x['metadata']['uid'] and o.get('controller') for o in c['metadata']['ownerReferences'])
PY
exit 0
