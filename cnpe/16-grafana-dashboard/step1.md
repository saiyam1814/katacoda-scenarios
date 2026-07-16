# Add the PromLab datasource

Expose Grafana on the lab's public port:

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
3. **Connection → Prometheus server URL:** `http://prom.obs.svc:9090`
4. Leave auth off, toggle **Default** on
5. **Save & test** → “Successfully queried the Prometheus API”

<details><summary>✦ Backup — pure API (if the UI misbehaves)</summary>

```bash
curl -s -X POST http://localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -u admin:admin \
  -d '{"name":"PromLab","type":"prometheus","url":"http://prom.obs.svc:9090","access":"proxy","isDefault":true}' | python3 -m json.tool
```{{exec}}

</details>

<details><summary>✦ Why `prom.obs.svc:9090`?</summary>

Grafana runs **inside** the cluster, so it reaches Prometheus through the Service DNS
name `<service>.<namespace>.svc` — not `localhost`, not a NodePort. Datasource access
mode `proxy` (Server) means the Grafana backend makes that request.

</details>
