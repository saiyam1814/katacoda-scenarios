#!/bin/bash
kubectl -n monitoring port-forward svc/prometheus-main 9099:9090 >/dev/null 2>&1 &
PF=$!
sleep 3

curl -s http://localhost:9099/api/v1/rules > /tmp/.prom-rules.json 2>/dev/null
kill $PF 2>/dev/null

python3 <<'PYEOF' || exit 1
import json
d = json.load(open("/tmp/.prom-rules.json"))
found = None
for g in d["data"]["groups"]:
    for r in g["rules"]:
        if r.get("name") == "FrontendHighErrorRate":
            found = r
assert found, "rule not loaded into Prometheus"
# pending or firing both prove the expression is live and true
assert found.get("state") in ("pending", "firing"), found.get("state")
PYEOF
exit 0
