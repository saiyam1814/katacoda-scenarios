#!/bin/bash
# Query the Grafana API through a short-lived port-forward
kubectl -n monitoring port-forward svc/grafana 3999:80 >/dev/null 2>&1 &
PF=$!
sleep 3

DS=$(curl -s -u admin:admin http://localhost:3999/api/datasources 2>/dev/null)
kill $PF 2>/dev/null

python3 - "$DS" <<'PYEOF' || exit 1
import json, sys
ds = json.loads(sys.argv[1])
match = [d for d in ds if d.get("name") == "PromLab"]
assert match, "no datasource named PromLab"
d = match[0]
assert d["type"] == "prometheus"
assert d["url"].rstrip("/") == "http://prom.obs.svc:9090"
assert d.get("isDefault") is True
PYEOF
exit 0
