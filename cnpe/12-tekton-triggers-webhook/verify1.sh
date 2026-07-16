#!/bin/bash
TT=$(kubectl -n ci-otter get triggertemplate build-ship-tt -o json 2>/dev/null) || exit 1
TB=$(kubectl -n ci-otter get triggerbinding build-ship-tb -o json 2>/dev/null) || exit 1
EL=$(kubectl -n ci-otter get eventlistener build-ship-el -o json 2>/dev/null) || exit 1

python3 - "$TT" "$TB" "$EL" <<'PYEOF' || exit 1
import json, sys
tt, tb, el = (json.loads(a) for a in sys.argv[1:4])

# template stamps a PipelineRun of build-ship with the param wired
rts = tt["spec"]["resourcetemplates"]
pr = rts[0]
assert pr["kind"] == "PipelineRun"
assert pr["spec"]["pipelineRef"]["name"] == "build-ship"
body = json.dumps(pr)
assert "tt.params.gitrevision" in body

# binding maps body.after
params = {p["name"]: p.get("value", "") for p in tb["spec"]["params"]}
assert params.get("gitrevision") == "$(body.after)"

# listener uses the SA and wires binding+template
assert el["spec"].get("serviceAccountName") == "tekton-triggers"
trig = el["spec"]["triggers"][0]
bindings = [b.get("ref") for b in trig.get("bindings", [])]
assert "build-ship-tb" in bindings
assert trig.get("template", {}).get("ref") == "build-ship-tt"
PYEOF

# the listener pod materialized and is ready
kubectl -n ci-otter wait --for=condition=available deploy/el-build-ship-el --timeout=60s >/dev/null 2>&1 || exit 1

exit 0
