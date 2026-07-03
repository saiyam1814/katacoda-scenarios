# Step 6: See the Impact - Krkn's Web UI

Exit codes tell your pipeline *whether* the system survived. But to understand *how* it behaved under chaos, you want graphs. **krkn-visualize** is Krkn's Grafana-based web UI: `krknctl` deploys it into your cluster preloaded with dashboards for every scenario type.

## Make Sure the Monitoring Stack Is Ready

The environment prepared a minimal Prometheus (server + node-exporter + kube-state-metrics) in the background for the dashboards to read from:

```bash
until [ -f /tmp/.krkn-visualize-ready ]; do echo "waiting for web UI prerequisites..."; sleep 5; done
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=180s
kubectl get pods -n monitoring
```{{exec}}

## Deploy the Krkn Web UI

One command deploys Grafana with the Krkn dashboards and wires it to Prometheus:

```bash
krknctl visualize \
  --grafana-password chaos \
  --prometheus-url http://prometheus-server.monitoring.svc.cluster.local:80
```{{exec}}

Wait for it to come up:

```bash
kubectl wait --for=condition=available deployment/krkn-visualize -n krkn-visualize --timeout=180s
kubectl get pods -n krkn-visualize
```{{exec}}

## Open It in Your Browser

Forward the Grafana port and open the UI:

```bash
kubectl port-forward svc/krkn-visualize -n krkn-visualize --address 0.0.0.0 3000:3000 > /dev/null 2>&1 &
sleep 2
curl -s -o /dev/null -w "krkn-visualize HTTP status: %{http_code}\n" http://localhost:3000
```{{exec}}

**[Open the Krkn Web UI]({{TRAFFIC_HOST1_3000}})**

Log in with username **admin** and password **chaos**.

## Watch Chaos Happen on a Graph

In Grafana, go to **Dashboards**, open the **k8s** folder, and select the **K8s Performance** dashboard. The **Cluster Prometheus** datasource is pre-selected. Set the time range to the last 15 minutes and auto-refresh to 5s.

> **Heads-up on the Chaos folder**: those per-scenario dashboards read Krkn's run telemetry from an **Elasticsearch/OpenSearch** datasource (`--es-url`). We didn't deploy Elasticsearch in this playground, so opening them shows a plugin error - that's expected here, not a broken install. In production, that folder is where teams track recovery times and resilience trends across hundreds of runs.

Now hit the cluster with another CPU hog and watch it land on the graphs:

```bash
krknctl run node-cpu-hog \
  --node-selector "kubernetes.io/hostname=node01" \
  --chaos-duration 120 \
  --cores 1 \
  --cpu-percentage 90 \
  --namespace default \
  --detached
```{{exec}}

Within a minute, node01's CPU panels climb - you're watching your chaos experiment through the same lens your on-call engineers would see a real incident.

> **The Chaos dashboards folder**: krkn-visualize also ships per-scenario dashboards (pod scenarios, hogs, network chaos...) that visualize Krkn's **run telemetry** - recovery times, affected pods, scenario timelines. Those populate when Krkn ships telemetry to Elasticsearch/OpenSearch (`--es-url`), which is how production teams track resilience trends across hundreds of runs.
