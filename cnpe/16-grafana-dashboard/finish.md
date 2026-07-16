# Dashboard delivered! 🎉

You wired the classic observability pair: Prometheus scrapes, Grafana queries.

## Key facts to remember

- In-cluster datasource URLs use Service DNS: `http://<svc>.<ns>.svc:<port>`
- "Default" datasource = what new panels use automatically; the exam often specifies it
- `rate(counter[5m])` = per-second rate over 5 minutes — **the** PromQL idiom.
  Raw counters only go up; you almost always graph their rate
- Save twice: **Save & test** on the datasource, 💾 on the dashboard —
  unsaved dashboards score zero
- The Grafana HTTP API (`/api/datasources`, `/api/dashboards/db`) is scriptable backup

📖 This lab is **Chapter 16** of the *CNPE Scenarios and Solutions* book.

Next lab: **17 — Alert when HTTP error rate spikes**.
