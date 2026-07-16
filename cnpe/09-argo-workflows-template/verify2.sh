#!/bin/bash
# A workflow from deploy-kit succeeded
kubectl -n workflows get workflows -o json 2>/dev/null | \
  python3 -c "
import json, sys
wfs = json.load(sys.stdin)['items']
ok = [w for w in wfs if w.get('status', {}).get('phase') == 'Succeeded'
      and (w.get('spec', {}).get('workflowTemplateRef', {}).get('name') == 'deploy-kit'
           or 'deploy-kit' in w['metadata']['name'])]
sys.exit(0 if ok else 1)
" || exit 1

# The Deployment it created is correct and available
[ "$(kubectl -n demo-reef get deploy catalog-ui -o jsonpath='{.spec.replicas}' 2>/dev/null)" = "3" ] || exit 1
IMG=$(kubectl -n demo-reef get deploy catalog-ui -o jsonpath='{.spec.template.spec.containers[0].image}')
[ "$IMG" = "httpd:2.4" ] || exit 1
kubectl -n demo-reef wait --for=condition=available deploy/catalog-ui --timeout=10s >/dev/null 2>&1 || exit 1

exit 0
