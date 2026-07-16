#!/bin/bash
kubectl -n workflows get workflows -o json 2>/dev/null | \
python3 -c "
import json, sys
wfs = json.load(sys.stdin)['items']
for w in wfs:
    if not w['metadata']['name'].startswith('release-checker-'):
        continue
    if w.get('status', {}).get('phase') != 'Succeeded':
        continue
    # find the main steps template and confirm order deploy -> ready-check -> test
    tpls = {t['name']: t for t in w['spec']['templates']}
    main = None
    for t in w['spec']['templates']:
        if 'steps' in t:
            main = t
    if not main:
        continue
    order = [stage[0]['name'] for stage in main['steps'] if stage]
    if order != ['deploy', 'ready-check', 'test']:
        continue
    if main['steps'][1][0].get('template') != 'wait-ready':
        continue
    wr = tpls.get('wait-ready', {})
    img = wr.get('container', {}).get('image', '')
    args = ' '.join(wr.get('container', {}).get('args', []))
    if img != 'rancher/kubectl:v1.28.0':
        continue
    if 'rollout status' not in args or 'checkout-api' not in args:
        continue
    # deploy and test templates still exist
    if 'deploy' not in tpls or 'test' not in tpls:
        continue
    # all three nodes actually ran and succeeded
    nodes = w.get('status', {}).get('nodes', {})
    names = [n.get('displayName') for n in nodes.values() if n.get('phase') == 'Succeeded']
    if all(x in names for x in ('deploy', 'ready-check', 'test')):
        sys.exit(0)
sys.exit(1)
" || exit 1
exit 0
