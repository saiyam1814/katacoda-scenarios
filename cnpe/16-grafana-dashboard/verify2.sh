#!/bin/bash
kubectl -n monitoring port-forward svc/grafana 3999:80 >/dev/null 2>&1 &
PF=$!
sleep 3

curl -s -u admin:admin "http://localhost:3999/api/search?query=coral-dashboard" > /tmp/.graf-search.json 2>/dev/null
DASH_UID=$(python3 -c "
import json
try:
    r = json.load(open('/tmp/.graf-search.json'))
    hits = [d for d in r if d.get('title') == 'coral-dashboard']
    print(hits[0]['uid'] if hits else '')
except Exception:
    print('')
")
if [ -z "$DASH_UID" ]; then kill $PF 2>/dev/null; exit 1; fi

curl -s -u admin:admin "http://localhost:3999/api/dashboards/uid/$DASH_UID" > /tmp/.graf-dash.json 2>/dev/null
kill $PF 2>/dev/null

python3 <<'PYEOF' || exit 1
import json
d = json.load(open("/tmp/.graf-dash.json"))["dashboard"]
ok = False
for p in d.get("panels", []):
    if p.get("title") != "Request Mix":
        continue
    if p.get("type") != "timeseries":
        continue
    for t in p.get("targets", []):
        if "rate(http_requests_total[5m])" in t.get("expr", "").replace(" ", ""):
            ok = True
assert ok
PYEOF
exit 0
