#!/bin/bash
T=$(kubectl -n ci-otter get task scan-image -o json 2>/dev/null) || exit 1
P=$(kubectl -n ci-otter get pipeline build-ship -o json 2>/dev/null) || exit 1

python3 - "$T" "$P" <<'PYEOF' || exit 1
import json, sys
t, p = json.loads(sys.argv[1]), json.loads(sys.argv[2])

# Task: trivy image with exit-code 1 and CRITICAL severity
body = json.dumps(t["spec"]["steps"])
assert "trivy" in body
assert "--exit-code 1" in body or "--exit-code=1" in body
assert "CRITICAL" in body
params = {x["name"] for x in t["spec"].get("params", [])}
assert "image" in params

# Pipeline: image -> scan -> deploy
tasks = {x["name"]: x for x in p["spec"]["tasks"]}
assert "scan" in tasks, "no scan task in pipeline"
scan = tasks["scan"]
assert scan.get("taskRef", {}).get("name") == "scan-image"
assert "image" in scan.get("runAfter", [])
sp = {x["name"]: x.get("value") for x in scan.get("params", [])}
assert sp.get("image") == "$(tasks.image.results.image-url)"
deploy = tasks["deploy"]
assert "scan" in deploy.get("runAfter", []), "deploy does not wait for scan - gate bypassable!"
PYEOF
exit 0
