# Step 4: Node Chaos - CPU Hog on a Worker

Killing pods tests your *controllers*. But real incidents often start lower in the stack: a noisy neighbor eats all the CPU, a memory leak starves the node. Krkn's **hog scenarios** simulate exactly that.

## How It Works

`node-cpu-hog` deploys a stress pod onto a target node and burns CPU for a fixed duration:

```
   +--------------------------------------+
   |  node01                              |
   |   +--------------+   +------------+  |
   |   | your pods    |   | krkn hog   |  |
   |   | (squeezed!)  |   | pod: burns |  |
   |   |              |   | CPU cores  |  |
   |   +--------------+   +------------+  |
   +--------------------------------------+
```

While the hog runs, you can observe how the node and your workloads behave under pressure.

## Target node01 Specifically

Instead of letting Krkn pick a random node, target `node01` by label - 1 core at 90% for 60 seconds. The `--detached` flag runs the scenario in the background so we can observe its effects live:

```bash
krknctl run node-cpu-hog \
  --node-selector "kubernetes.io/hostname=node01" \
  --chaos-duration 60 \
  --cores 1 \
  --cpu-percentage 90 \
  --namespace default \
  --detached
```{{exec}}

## Watch the Hog Land on the Node

Within ~30 seconds you should see the hog pod appear in the `default` namespace, scheduled on `node01`:

```bash
kubectl get pods -n default -o wide -w
```{{exec interrupt}}

Press `Ctrl+C` once you see the hog pod `Running` on `node01`.

## Observe the Pressure

While the hog burns CPU, check the load on node01 directly:

```bash
ssh node01 "uptime && top -bn1 | head -5"
```{{exec}}

Look at the **load average** and the `%Cpu` line - a chunk of the node's CPU is pinned by the stress workload. In production, this is where you'd watch your latency dashboards and autoscaler behavior.

## Wait for Completion and Query the Result

The scenario cleans up after itself - the hog pod is removed when the duration expires. The container keeps running a bit longer than the 60s of chaos (krkn adds a cool-down wait after the scenario), so expect this to loop for a couple of minutes. Wait for the detached run to finish, then query its status like you learned in Step 3:

```bash
until [ -z "$(podman ps -q --filter 'name=krknctl-node-cpu-hog')" ]; do echo "chaos still running..."; sleep 10; done
LAST_RUN=$(podman ps -a --filter "name=krknctl-node-cpu-hog" --format "{{.Names}}" | head -1)
krknctl query-status "$LAST_RUN"
kubectl get pods -n default
```{{exec}}

The hog pod is gone, the node is back to normal, and the scenario reported its exit status.

> **In production** you'd combine this with SLO monitoring: does your app still meet latency targets when a node loses a core? Krkn can even watch Prometheus alerts during chaos and fail the run if critical alerts fire (that's exit code `2`).
