#!/bin/bash
C=$(kubectl -n release-bay get canary media-proxy -o json 2>/dev/null) || exit 1

python3 - "$C" <<'PYEOF' || exit 1
import json, sys
c = json.loads(sys.argv[1])
spec = c["spec"]
assert spec["targetRef"]["kind"] == "Deployment"
assert spec["targetRef"]["name"] == "media-proxy"
assert spec.get("progressDeadlineSeconds") == 300
assert spec["service"]["port"] == 80
a = spec["analysis"]
assert a["interval"] == "20s"
assert a["threshold"] == 3
assert a["stepWeight"] == 20
assert a["maxWeight"] == 100
m = [x for x in a["metrics"] if x["name"] == "request-success-rate"]
assert m, "request-success-rate metric missing"
assert m[0]["thresholdRange"]["min"] == 99
PYEOF

# canary must be initialized (primary generated and healthy)
PHASE=$(kubectl -n release-bay get canary media-proxy -o jsonpath='{.status.phase}')
[ "$PHASE" = "Initialized" ] || [ "$PHASE" = "Succeeded" ] || [ "$PHASE" = "Progressing" ] || exit 1
kubectl -n release-bay get deploy media-proxy-primary >/dev/null 2>&1 || exit 1
kubectl -n release-bay get virtualservice media-proxy >/dev/null 2>&1 || exit 1
exit 0
