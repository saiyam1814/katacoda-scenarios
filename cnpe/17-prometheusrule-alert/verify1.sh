#!/bin/bash
R=$(kubectl -n monitoring get prometheusrule frontend-slo -o json 2>/dev/null) || exit 1

python3 - "$R" <<'PYEOF' || exit 1
import json, sys
r = json.loads(sys.argv[1])
# must match the Prometheus ruleSelector
assert r["metadata"].get("labels", {}).get("release") == "prometheus"
rules = []
for g in r["spec"]["groups"]:
    rules.extend(g.get("rules", []))
alerts = [x for x in rules if x.get("alert") == "FrontendHighErrorRate"]
assert alerts, "alert FrontendHighErrorRate not found"
a = alerts[0]
expr = a["expr"].replace(" ", "").replace("\n", "")
assert "5.." in expr and "http_requests_total" in expr
assert "/" in expr and ">0.05" in expr
assert a.get("for") == "5m"
assert a.get("labels", {}).get("severity") == "warning"
PYEOF

exit 0
