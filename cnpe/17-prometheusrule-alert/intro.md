# Alert when HTTP Error Rate Spikes

**Domain:** Observability and Operations &nbsp;|&nbsp; **Suggested time:** 12 minutes

The frontend team's SLO: **less than 5% of requests may fail**. Prometheus (managed by
the **Prometheus Operator**) already scrapes the app's `http_requests_total{status=…}`
counters. Nobody gets paged when things burn - fix that.

Create a **PrometheusRule** named **`frontend-slo`** in namespace **`monitoring`** that:

- Fires an alert named **`FrontendHighErrorRate`**
- When the ratio of **5xx requests to total requests over 5 minutes exceeds 5%**
- Only after the condition holds **for 5 minutes** (no flapping pages)
- With label **`severity: warning`**
- And carries labels so the Prometheus instance actually **selects** it
  (inspect the `Prometheus` object to find its `ruleSelector`!)

The lab app is already erroring at ~8% - your alert should go Pending, then **Firing**.

Click **START** while the operator installs.
