# Step 5: Orchestrate Multiple Scenarios with Graphs

Real incidents rarely arrive one at a time. A node gets starved *while* pods are dying. Krkn's **graph runner** lets you chain scenarios into a dependency graph: serial chains, parallel bursts, or a mix.

## Scaffold a Plan

`krknctl graph scaffold` generates a plan template for any list of scenarios:

```bash
krknctl graph scaffold pod-scenarios node-cpu-hog | head -30
```{{exec}}

Each node in the plan has an ID, its scenario image, an `env` block for parameters, and a `depends_on` field that defines the execution order. Nodes without dependencies run first; nodes sharing the same parent run **in parallel**.

## Create Your Chaos Plan

Let's build a two-stage plan tuned for our cluster: first kill a pod in `demo`, and once that scenario completes, hog the CPU on `node01`:

```bash
cat <<'EOF' > /root/chaos-plan.json
{
  "kill-nginx-pod": {
    "image": "quay.io/krkn-chaos/krkn-hub:pod-scenarios",
    "name": "pod-scenarios",
    "env": {
      "NAMESPACE": "demo",
      "POD_LABEL": "app=nginx",
      "DISRUPTION_COUNT": "1",
      "EXPECTED_RECOVERY_TIME": "120"
    }
  },
  "stress-node01": {
    "image": "quay.io/krkn-chaos/krkn-hub:node-cpu-hog",
    "name": "node-cpu-hog",
    "env": {
      "NODE_SELECTOR": "kubernetes.io/hostname=node01",
      "TOTAL_CHAOS_DURATION": "30",
      "NODE_CPU_CORE": "1",
      "NODE_CPU_PERCENTAGE": "80",
      "NAMESPACE": "default"
    },
    "depends_on": "kill-nginx-pod"
  }
}
EOF
cat /root/chaos-plan.json
```{{exec}}

Note `stress-node01` **depends on** `kill-nginx-pod`, making this a serial chain. Remove the `depends_on` and both would fire at once.

## Run the Graph

```bash
krknctl graph run /root/chaos-plan.json
```{{exec}}

Watch the stages execute in order: the pod kill completes (and recovery is verified), *then* the CPU hog starts. Each stage includes krkn's cool-down wait, so the full campaign takes about 4 minutes.

## Confirm the Cluster Survived

```bash
kubectl get pods -n demo
kubectl get nodes
```{{exec}}

Full strength: 3/3 nginx replicas, both nodes `Ready`. Your cluster just survived a multi-stage chaos campaign.

> **Where to go from here**: `krknctl random run` executes plans in randomized order for game days, and the full `krkn` engine adds Prometheus alert checks, cluster health monitoring with Cerberus, and telemetry to Elasticsearch - everything you need for chaos in CI.
