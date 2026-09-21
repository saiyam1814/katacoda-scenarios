# Add the PromLab datasource

First discover the Prometheus Service and its port:

```bash
kubectl -n obs get svc
kubectl -n obs get svc prom -o yaml
```{{exec}}

The Service is `prom`, its namespace is `obs`, and its port is 9090. With this
cluster's `cluster.local` DNS domain, the full name is
`prom.obs.svc.cluster.local`. The shorter `prom.obs.svc` also resolves inside
this cluster.

Use a direct Grafana link when supplied. Otherwise expose it for this lab:

```bash
kubectl -n monitoring port-forward --address 0.0.0.0 svc/grafana 3000:80 >/dev/null 2>&1 &
sleep 2
echo "Grafana is up"
```{{exec}}

Open Grafana: [click here to open port 3000]({{TRAFFIC_HOST1_3000}})
(anonymous admin is enabled; `admin`/`admin` also works).

**In the UI:**

1. Left menu → **Connections → Data sources → Add data source → Prometheus**
2. **Name:** `PromLab`
3. **Connection → Prometheus server URL:** `http://prom.obs.svc.cluster.local:9090`
4. Leave auth off, toggle **Default** on
5. **Save & test** → “Successfully queried the Prometheus API”

<details><summary>✦ Why `prom.obs.svc:9090`?</summary>

Grafana runs **inside** the cluster, so it reaches Prometheus through the Service DNS
name `<service>.<namespace>.svc` - not `localhost`, not a NodePort. Datasource access
mode `proxy` (Server) means the Grafana backend makes that request.

</details>
