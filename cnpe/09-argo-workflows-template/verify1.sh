#!/bin/bash
WT=$(kubectl -n workflows get workflowtemplate deploy-kit -o json 2>/dev/null) || exit 1

python3 - "$WT" <<'PYEOF' || exit 1
import json, sys
wt = json.loads(sys.argv[1])
spec = wt["spec"]
assert spec.get("serviceAccountName") == "workflow-runner"

params = {p["name"] for p in spec.get("arguments", {}).get("parameters", [])}
assert {"appName", "targetNs", "count", "containerImage"} <= params, params

tmpl = [t for t in spec["templates"] if "resource" in t]
assert len(tmpl) >= 1
res = tmpl[0]["resource"]
assert res["action"] == "apply"
m = res["manifest"]
assert "kind: Deployment" in m
for ref in ("appName", "targetNs", "count", "containerImage"):
    assert "inputs.parameters.%s" % ref in m, ref
PYEOF

exit 0
