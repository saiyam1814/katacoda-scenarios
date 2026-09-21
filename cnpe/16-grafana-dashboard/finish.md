# Dashboard delivered! 🎉

Grafana now queries the Prometheus datasource and plots the requested metrics.

## Key facts to remember

- In-cluster datasource URLs use Service DNS: `http://<svc>.<ns>.svc:<port>`
- "Default" datasource = what new panels use automatically; this task requires it
- `rate(counter[5m])` = per-second rate over 5 minutes - **the** PromQL idiom.
  Counters accumulate until a reset; graph their rate when you need requests per second
- Save twice: **Save & test** on the datasource, 💾 on the dashboard - 
  unsaved dashboards score zero
- The Grafana HTTP API (`/api/datasources`, `/api/dashboards/db`) is scriptable backup

📖 This lab is **Chapter 16** of the *CNPE Scenarios and Solutions* book.

Next lab: **17 - Alert when HTTP error rate spikes**.
