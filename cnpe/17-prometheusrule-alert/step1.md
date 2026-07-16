# Create the PrometheusRule

First — the step everyone skips and regrets: find out which labels the Prometheus
instance uses to pick up rules:

```bash
kubectl -n monitoring get prometheus main -o jsonpath='{.spec.ruleSelector}' ; echo
```{{exec}}

Now write the rule. The expression pattern for an error *ratio*:

```
sum(rate(errors[5m])) / sum(rate(total[5m])) > threshold
```

The app labels 5xx requests with `status="500"`.

<details><summary>✦ Tip — PrometheusRule anatomy</summary>

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: ...
  namespace: monitoring
  labels:
    release: prometheus        # <- must match the ruleSelector!
spec:
  groups:
    - name: <group-name>
      rules:
        - alert: <AlertName>
          expr: <promql>
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: ...
```{{copy}}

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: frontend-slo
  namespace: monitoring
  labels:
    release: prometheus
spec:
  groups:
    - name: frontend.slo
      rules:
        - alert: FrontendHighErrorRate
          expr: |
            sum(rate(http_requests_total{status=~"5.."}[5m]))
              /
            sum(rate(http_requests_total[5m]))
              > 0.05
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Frontend 5xx ratio above 5%"
            description: "Error ratio is {{ $value | humanizePercentage }}"
EOF
```{{exec}}

```plain
kubectl -n monitoring get prometheusrule frontend-slo
```{{exec}}

</details>
