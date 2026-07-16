#!/bin/bash
RO=$(kubectl -n release-bay get rollout media-proxy -o json 2>/dev/null) || exit 1

python3 - "$RO" <<'PYEOF' || exit 1
import json, sys
ro = json.loads(sys.argv[1])
spec = ro["spec"]
assert spec.get("replicas") == 3
canary = spec["strategy"]["canary"]
assert canary["canaryService"] == "media-proxy-canary"
assert canary["stableService"] == "media-proxy-stable"
istio = canary["trafficRouting"]["istio"]["virtualService"]
assert istio["name"] == "media-proxy"
routes = istio.get("routes", [])
assert "primary" in routes
steps = canary["steps"]
weights = [s.get("setWeight") for s in steps if "setWeight" in s]
assert weights == [20, 40, 100], weights
pauses = [s for s in steps if "pause" in s]
assert len(pauses) >= 2
PYEOF

# Rollout must reach Healthy
PHASE=$(kubectl -n release-bay get rollout media-proxy -o jsonpath='{.status.phase}')
[ "$PHASE" = "Healthy" ] || exit 1

exit 0
