#!/bin/bash
set -euo pipefail
kubectl -n compose-sandbox get xwebapp demo-site -o json > /tmp/cnpe14-xr.json
kubectl -n compose-sandbox get deployment demo-site -o json > /tmp/cnpe14-deploy.json
kubectl -n compose-sandbox get service demo-site -o json > /tmp/cnpe14-svc.json
kubectl -n compose-sandbox get endpointslices -l kubernetes.io/service-name=demo-site -o json > /tmp/cnpe14-endpoints.json
python3 - <<'PY'
import json
def read(n): return json.load(open('/tmp/cnpe14-'+n+'.json'))
x,d,s,e=[read(n) for n in ['xr','deploy','svc','endpoints']]
assert all(any(c['type']==t and c['status']=='True' for c in x['status']['conditions']) for t in ['Ready','Synced'])
assert x['metadata']['namespace']=='compose-sandbox'
assert d['spec']['replicas']==2 and d['status'].get('availableReplicas',0)==2
assert d['spec']['template']['spec']['containers'][0]['image']=='nginx:1.25'
assert d['spec']['selector']['matchLabels']['app']=='demo-site'
assert d['spec']['template']['metadata']['labels']['app']=='demo-site'
assert s['spec']['selector']['app']=='demo-site'
assert any(p['port']==80 and p['targetPort']==80 for p in s['spec']['ports'])
assert any(ep.get('conditions',{}).get('ready') for item in e['items'] for ep in item.get('endpoints',[]))
for resource in [d,s]:
    assert any(o['uid']==x['metadata']['uid'] and o.get('controller') for o in resource['metadata']['ownerReferences'])
PY
exit 0
