# Read costs from OpenCost

OpenCost exposes an **allocation API** on port 9003 and a UI on port 9090.
The `kubectl cost` plugin is installed too.

**Option A - kubectl cost plugin** (points at OpenCost, not Kubecost):

```bash
kubectl cost namespace \
  --service-name opencost --service-port 9003 -N opencost \
  --allocation-path /allocation/compute \
  --window 10m --show-cpu --show-memory
```{{exec}}

(`--allocation-path /allocation/compute` is required: the plugin's default path
`/model/allocation` exists only on Kubecost, not OpenCost.)

**Option B - raw allocation API:**

```bash
kubectl -n opencost port-forward svc/opencost 9003:9003 >/dev/null 2>&1 &
sleep 3
curl -s "http://localhost:9003/allocation/compute?window=10m&aggregate=namespace" | \
  python3 -m json.tool | grep -E '"name"|totalCost' | head -20
```{{exec}}

**Option C - OpenCost UI:** open it via [Traffic Port 9090]({{TRAFFIC_HOST1_9090}})
after: `kubectl -n opencost port-forward --address 0.0.0.0 svc/opencost 9090:9090 &`

If costs still show as zero, wait ~60s for the first Prometheus scrape cycle and rerun.

When you know the answer, record it:

```bash
echo "<deployment-name>" > /root/cheapest.txt
echo "<deployment-name>" > /root/expensive.txt
```{{copy}}

<details><summary>✦ Tip - reading the output</summary>

Cost here is dominated by **resource requests** (CPU minutes and GiB hours reserved).
More replicas × bigger requests = bigger bill. The `--window 10m` flag limits the
query to the last 10 minutes, which is all this fresh cluster has.

</details>

<details><summary>✅ Solution</summary>

`api-gamma` (3 replicas × 300m CPU / 384Mi) dwarfs the others;
`api-alpha` (1 × 25m / 32Mi) is the cheapest.

```bash
echo "api-alpha" > /root/cheapest.txt
echo "api-gamma" > /root/expensive.txt
```{{exec}}

</details>
