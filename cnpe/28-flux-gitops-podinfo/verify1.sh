#!/bin/bash
set -euo pipefail
kubectl -n flux-system get gitrepository podinfo -o json > /tmp/cnpe28-source.json
kubectl -n flux-system get helmrelease podinfo-ui -o json > /tmp/cnpe28-release.json
python3 - <<'PY'
import json
g=json.load(open('/tmp/cnpe28-source.json')); h=json.load(open('/tmp/cnpe28-release.json'))
assert g['spec']['url']=='https://github.com/stefanprodan/podinfo'
assert g['spec']['ref']['branch']=='master'
s=h['spec']; assert s['targetNamespace']=='apps-ui' and s['releaseName']=='podinfo-ui'
c=s['chart']['spec']; assert c['chart']=='charts/podinfo' and c['reconcileStrategy']=='Revision'
assert c['sourceRef']['kind']=='GitRepository' and c['sourceRef']['name']=='podinfo'
assert s['install']['createNamespace'] and s['driftDetection']['mode']=='enabled'
assert s['values']['replicaCount']==2 and s['values']['service']['type']=='ClusterIP'
assert s['values']['ui']['color']=='#336699'
PY
exit 0
