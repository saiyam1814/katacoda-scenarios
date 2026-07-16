#!/bin/bash
# Claim exists and is Ready
kubectl -n team-apps get bucketapp media-assets >/dev/null 2>&1 || exit 1
READY=$(kubectl -n team-apps get bucketapp media-assets -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
[ "$READY" = "True" ] || exit 1

# A composed ConfigMap landed in bucket-system with the claim's values
kubectl -n bucket-system get cm -o json | python3 -c "
import json, sys
cms = json.load(sys.stdin)['items']
ok = any(
    cm['metadata']['name'].startswith('media-assets')
    and cm.get('data', {}).get('region') == 'eu-west-1'
    and cm.get('data', {}).get('size') == 'small'
    for cm in cms
)
sys.exit(0 if ok else 1)
" || exit 1

exit 0
