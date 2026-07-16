#!/bin/bash
# Pipeline has the apply task wired correctly
P=$(kubectl -n pipeline-lab get pipeline compile-release -o json 2>/dev/null) || exit 1
python3 - "$P" <<'PYEOF' || exit 1
import json, sys
p = json.loads(sys.argv[1])
tasks = {t["name"]: t for t in p["spec"]["tasks"]}
assert "build" in tasks and "package" in tasks
apply = [t for t in p["spec"]["tasks"] if t.get("taskRef", {}).get("name") == "kubectl-apply"]
assert apply, "no task references kubectl-apply"
a = apply[0]
ra = set(a.get("runAfter", []))
assert {"build", "package"} <= ra, ra
params = {pp["name"]: pp.get("value", "") for pp in a.get("params", [])}
assert params.get("manifest") == "$(tasks.package.results.manifest)"
PYEOF

# A PipelineRun of compile-release succeeded
kubectl -n pipeline-lab get pipelinerun -o json 2>/dev/null | python3 -c "
import json, sys
prs = json.load(sys.stdin)['items']
ok = False
for pr in prs:
    if pr.get('spec', {}).get('pipelineRef', {}).get('name') != 'compile-release':
        continue
    for c in pr.get('status', {}).get('conditions', []):
        if c.get('type') == 'Succeeded' and c.get('status') == 'True':
            ok = True
sys.exit(0 if ok else 1)
" || exit 1

# The applied Deployment exists and is available
kubectl -n pipeline-lab wait --for=condition=available deploy/compiled-web --timeout=10s >/dev/null 2>&1 || exit 1

exit 0
