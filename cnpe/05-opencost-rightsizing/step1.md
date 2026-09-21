# Read costs from OpenCost

OpenCost exposes an **allocation API** on port 9003 and a UI on port 9090.
The optional `kubectl cost` plugin is installed on Linux amd64. On other
architectures, use the UI or allocation API.

**Using the UI:** open [OpenCost on port 9090]({{TRAFFIC_HOST1_9090}}) after running:

```bash
kubectl -n opencost port-forward --address 0.0.0.0 svc/opencost 9090:9090 >/dev/null 2>&1 &
```{{exec}}

On **Home**, find **Cost Allocation** and open its filter-options control. Older
versions may have a separate **Allocations** page. Select **Today** or another
window with collected data, set **Aggregate by** to **Deployment**, and compare
`api-alpha`, `api-beta` and `api-gamma` in the cost table. Sort **Total cost** and
record the lowest and highest of those three workloads. Use pagination if needed.
Keep the window and idle-cost settings consistent. If a task supplies a direct
OpenCost link, use that link.

Small fresh-lab costs may round to `$0.00`. The table can still sort them; use the
CLI or API below for greater precision if the ordering is unclear.

The plugin and API below provide the same underlying allocation data.

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

If costs still show as zero, wait ~60s for the first Prometheus scrape cycle and rerun.

When you know the answer, record it:

```bash
echo "<deployment-name>" > /root/cheapest.txt
echo "<deployment-name>" > /root/expensive.txt
```{{copy}}

<details><summary>✦ Tip - reading the output</summary>

Cost here is dominated by **resource requests** (CPU minutes and GiB hours reserved).
Inspect the reported values; usage, prices and the time window also affect allocations. The `--window 10m` flag limits the
query to the last 10 minutes, which is all this fresh cluster has.

</details>

<details><summary>✅ Solution</summary>

In this lab, `api-gamma` requests 3 replicas × 300m CPU / 384Mi;
`api-alpha` (1 × 25m / 32Mi) is the cheapest.

```bash
echo "api-alpha" > /root/cheapest.txt
echo "api-gamma" > /root/expensive.txt
```{{exec}}

</details>
