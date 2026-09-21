# Confirm Prometheus loaded the rule

Open the supplied Prometheus UI link. For this practice environment, expose it:

```bash
kubectl -n monitoring port-forward --address 0.0.0.0 svc/prometheus-main 9090:9090 >/dev/null 2>&1 &
```{{exec}}

Open [Prometheus on port 9090]({{TRAFFIC_HOST1_9090}}), then **Rules** (under
**Status** in some versions). Find `FrontendHighErrorRate` in `frontend.slo`.
Check its expression, `for: 5m`, labels and evaluation health. An object in
Kubernetes alone does not establish that Prometheus selected and loaded it.

In **Alerts**, inspect its state. The lab produces about 8% errors, so the alert
should become pending and, after the condition stays true for five minutes,
firing. For timed practice, check that it loaded first and return to the firing
check later.

In the query page, evaluate:

```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

The result should be near 0.08 once samples are available.

If the rule is missing, inspect selectors:

```bash
kubectl -n monitoring get prometheus main -o yaml
kubectl -n monitoring get prometheusrule frontend-slo --show-labels
```{{exec}}

The object's labels must match `ruleSelector`, and its namespace must match
`ruleNamespaceSelector`. A null namespace selector means the Prometheus object's
own namespace; `{}` selects all namespaces. An empty rule selector selects all
rules; a null rule selector selects none.
