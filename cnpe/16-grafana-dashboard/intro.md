# Wire PromLab and Build coral-dashboard

**Domain:** Observability and Operations &nbsp;|&nbsp; **Suggested time:** 12 minutes

The SRE guild wants a request-rate dashboard. Grafana runs in `monitoring`
(Service `grafana`, port 80). Prometheus runs in `obs` (Service `prom`, port 9090) and
already scrapes a shop app that exports `http_requests_total`.

**Your task - in Grafana:**

1. Add a **Prometheus datasource**:
   - Name **`PromLab`**
   - URL **`http://prom.obs.svc:9090`**
   - No auth, set as **default**
2. Create a dashboard titled **`coral-dashboard`** with one panel:
   - Type **Time series**
   - Title **`Request Mix`**
   - Query **`rate(http_requests_total[5m])`**
3. **Save** the dashboard and confirm the panel draws data

Do it in the UI (like the exam) - an API path is shown as backup.

Click **START** when ready.
