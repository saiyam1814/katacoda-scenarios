# Congratulations! You're a Chaos Engineer Now

## What You Accomplished

In about 20 minutes, you ran a complete chaos engineering workflow on a real Kubernetes cluster:

### Step 1: Built a Target
- Deployed a 3-replica nginx application and learned how Krkn targets workloads by label

### Step 2: First Chaos Experiment
- Killed a pod with `krknctl run pod-scenarios` and **proved** the Deployment self-healed

### Step 3: Found a Real Weakness
- Watched Krkn flag a naked pod that never recovered - and learned the exit codes (`0`/`1`/`2`/`3+`) that let chaos gate your CI/CD pipelines

### Step 4: Node-Level Chaos
- Stressed `node01` with a CPU hog and observed the pressure live

### Step 5: Chaos Campaigns
- Chained scenarios into a dependency graph with `krknctl graph run`

### Step 6: The Web UI
- Deployed krkn-visualize (Grafana) with `krknctl visualize` and watched a CPU hog land on live cluster dashboards

## From This Playground to Production

| You did today | Production version |
|----------------------------|--------------------------------------------|
| Kill 1 nginx pod | Disrupt etcd, DNS, or your own services |
| Watch `top` on a node | Prometheus alerts fail the run (exit `2`) |
| Manual `krknctl run` | Chaos stages in CI/CD pipelines |
| 2-node playground | OpenShift/K8s clusters on any cloud |

Krkn has many more scenarios waiting for you: network chaos, zone outages, time skew, service hijacking, PVC fill, node shutdown across AWS/Azure/GCP, and more. Run `krknctl list available` anywhere to explore.

## Keep Going

| Resource | Link |
|----------|------|
| Krkn documentation | [krkn-chaos.dev/docs](https://krkn-chaos.dev/docs/) |
| Krkn on GitHub (star it!) | [github.com/krkn-chaos/krkn](https://github.com/krkn-chaos/krkn) |
| krknctl CLI | [github.com/krkn-chaos/krknctl](https://github.com/krkn-chaos/krknctl) |
| Scenario catalog (krkn-hub) | [github.com/krkn-chaos/krkn-hub](https://github.com/krkn-chaos/krkn-hub) |
| Community Slack | [#krkn on Kubernetes Slack](https://kubernetes.slack.com/messages/C05SFMHRWK1) |

Krkn is a **CNCF project** - contributions are always welcome, from new scenarios to docs.

**Now go break things on purpose!**
