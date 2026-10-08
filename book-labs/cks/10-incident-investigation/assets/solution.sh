#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-10-incident-investigation
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
python3 - "$WORK_DIR" <<'PYREPORT'
import pathlib,json,sys
p=pathlib.Path(sys.argv[1]);rows=[json.loads(x) for x in (p/'incident.jsonl').read_text().splitlines()];actor='system:serviceaccount:book-cks-incident:actor'
def event(verb,ns,resource,name=None):return next(x for x in rows if x['verb']==verb and x.get('objectRef',{}).get('namespace')==ns and x['objectRef']['resource']==resource and (name is None or x['objectRef'].get('name')==name))
r=event('get','book-cks-incident','secrets','payments');denied=event('list','kube-system','secrets');deleted=event('delete','book-cks-incident','pods','victim')
json.dump({'actor':r['user']['username'],'sourceIP':r['sourceIPs'][0],'secretRead':r['responseStatus']['code'],'crossNamespaceRead':denied['responseStatus']['code'],'deletedPod':deleted['objectRef']['name'],'targetSecret':r['objectRef']['name'],'activity':[x['verb'] for x in sorted([r,denied,deleted],key=lambda x:x['requestReceivedTimestamp'])]},open(p/'findings.json','w'),indent=2)
(p/'response-plan.md').write_text('The metadata identifies the authenticated actor, source, object, verb and result without copying a Secret value. Revoke the binding and isolate the still-running Pod to preserve evidence. Deleting only the Pod does not revoke service-account authorization or prevent another workload from using that identity.\n')
PYREPORT
kubectl -n book-cks-incident delete rolebinding incident-access --ignore-not-found
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: quarantine-actor, namespace: book-cks-incident}
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
  ingress: []
  egress: []
YAML
for n in $(seq 1 30); do
 if ! kubectl -n book-cks-incident exec actor -- curl -fsS --max-time 2 "http://$(cat "$STATE_DIR/control-web-ip")/" >/dev/null 2>&1;then break;fi
 sleep 1
done
kubectl -n book-cks-incident get networkpolicy quarantine-actor -o yaml > "$WORK_DIR/containment.yaml"
