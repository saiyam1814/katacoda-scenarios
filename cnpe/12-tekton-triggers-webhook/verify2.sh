#!/bin/bash
# At least one webhook-spawned PipelineRun (generateName build-ship-) succeeded
kubectl -n ci-otter get pipelinerun -o json 2>/dev/null | python3 -c "
import json, sys
prs = json.load(sys.stdin)['items']
ok = False
for pr in prs:
    name = pr['metadata']['name']
    if not name.startswith('build-ship-'):
        continue
    # webhook runs get the param from the binding; manual smoke runs used 'manual-test'
    params = {p['name']: p.get('value') for p in pr.get('spec', {}).get('params', [])}
    if params.get('gitrevision') in (None, 'manual-test', 'main'):
        continue
    for c in pr.get('status', {}).get('conditions', []):
        if c.get('type') == 'Succeeded' and c.get('status') == 'True':
            ok = True
sys.exit(0 if ok else 1)
" || exit 1
exit 0
