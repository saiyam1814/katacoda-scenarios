# Confirm Prometheus loaded it - and watch it fire

Creating the object is half the job. **Prove Prometheus loaded it** - on the exam this
is the difference between full and zero marks (a rule with the wrong labels sits there,
silently ignored).

Expose Prometheus and check the Rules page:

```bash
kubectl -n monitoring port-forward --address 0.0.0.0 svc/prometheus-main 9090:9090 >/dev/null 2>&1 &
sleep 2
curl -s http://localhost:9090/api/v1/rules | python3 -c "
import json, sys
d = json.load(sys.stdin)
for g in d['data']['groups']:
    for r in g['rules']:
        print(r.get('name'), '-', r.get('state', r.get('type')))
"
```{{exec}}

Or visually: open [Prometheus on port 9090]({{TRAFFIC_HOST1_9090}}) → **Status → Rules**
and **Alerts**.

The lab app errors at ~8%, so the alert goes **pending** first (the `for: 5m` clock),
then **firing**. Watch it flip (this takes about 5 minutes - the point of `for:`):

```bash
watch -n 15 'curl -s http://localhost:9090/api/v1/alerts | python3 -m json.tool | grep -E "alertname|state"'
```{{exec interrupt}}

While you wait, sanity-check the ratio the alert computes - it should print ~0.08:

```bash
curl -s "http://localhost:9090/api/v1/query" \
  --data-urlencode 'query=sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))' \
  | python3 -c "import json,sys; r=json.load(sys.stdin)['data']['result']; print(r[0]['value'][1] if r else 'no data yet')"
```{{exec}}

<details><summary>✦ Rule not showing on the Rules page?</summary>

90% of the time: **label mismatch**. `kubectl -n monitoring get prometheus main -o
jsonpath='{.spec.ruleSelector}'` tells you what is expected on the PrometheusRule
object. The operator also requires the rule to be in a namespace matched by
`ruleNamespaceSelector` (empty = same namespace as the Prometheus object).

</details>
