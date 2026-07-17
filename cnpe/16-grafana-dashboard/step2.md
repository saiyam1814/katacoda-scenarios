# Build coral-dashboard

Back in the Grafana UI ([port 3000]({{TRAFFIC_HOST1_3000}})):

1. Left menu → **Dashboards → New → New dashboard**
2. **Add visualization** → pick **PromLab**
3. Bottom query editor → switch to **Code** → enter:
   `rate(http_requests_total[5m])` → **Run queries**
4. Right panel options → **Title:** `Request Mix`
5. Visualization type (top-right dropdown): **Time series**
6. **Apply / Back to dashboard**, then 💾 **Save dashboard** → title
   **`coral-dashboard`** → Save

You should see lines for the shop app's endpoints (`/` and `/err` - a traffic
generator hits them nonstop, and Prometheus has been scraping since setup).

<details><summary>✦ Backup - pure API</summary>

```bash
curl -s -X POST http://localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' -u admin:admin \
  -d '{
    "dashboard": {
      "title": "coral-dashboard",
      "panels": [{
        "type": "timeseries",
        "title": "Request Mix",
        "gridPos": {"h": 9, "w": 24, "x": 0, "y": 0},
        "targets": [{"expr": "rate(http_requests_total[5m])", "refId": "A"}]
      }]
    },
    "overwrite": true
  }' | python3 -m json.tool
```{{exec}}

</details>

<details><summary>✦ No data in the panel?</summary>

- Time range top-right: set **Last 15 minutes**
- Test the query in Prometheus directly:
  `kubectl -n obs port-forward --address 0.0.0.0 svc/prom 9090:9090 &` then open
  [port 9090]({{TRAFFIC_HOST1_9090}}) → run `http_requests_total`
- `rate()` needs at least 2 scrape samples - wait ~30s after setup

</details>
