#!/bin/bash
T=$(kubectl -n pipeline-lab get task kubectl-apply -o json 2>/dev/null) || exit 1

python3 - "$T" <<'PYEOF' || exit 1
import json, sys
t = json.loads(sys.argv[1])
spec = t["spec"]
params = {p["name"]: p for p in spec.get("params", [])}
assert "manifest" in params
assert params["manifest"].get("type", "string") == "string"
steps = spec["steps"]
assert any("kubectl" in s.get("image", "") for s in steps)
body = json.dumps(steps)
assert "kubectl apply -f" in body
assert "params.manifest" in body
PYEOF

exit 0
