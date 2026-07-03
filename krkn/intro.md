# Chaos Engineering with Krkn

## Break Your Cluster on Purpose (Before Production Does It for You)

**Krkn** (pronounced "kraken") is a [CNCF](https://www.cncf.io/) chaos engineering tool for Kubernetes and OpenShift. It injects deliberate failures into your cluster - killing pods, stressing nodes, disrupting networks - so you can find weaknesses **before** they cause a 3 AM page.

## Why Chaos Engineering?

Kubernetes promises self-healing. But do you *know* your workloads recover when:

- A pod gets OOM-killed mid-request?
- A node runs out of CPU?
- The network partitions?

Chaos engineering turns "we think it recovers" into "we proved it recovers".

## What You'll Do in ~25 Minutes

```
Step 1: Deploy a target application on a real 2-node cluster
Step 2: Run your first chaos experiment - kill pods with krknctl
Step 3: Read the results - recovery checks and exit codes
Step 4: Stress a worker node with a CPU hog scenario
Step 5: Chain multiple scenarios into one chaos run with graphs
Step 6: Watch chaos hit the graphs in Krkn's web UI (Grafana)
```

## The Krkn Toolbox

| Tool | What it is |
|------------|--------------------------------------------------|
| **krkn** | The chaos engine (Python, plugin-based) |
| **krkn-hub** | Pre-built container images, one per scenario |
| **krknctl** | CLI that runs krkn-hub scenarios - what we use today |

`krknctl` gives you chaos scenarios as simple commands: no config files, no Python environment, just `krknctl run pod-scenarios` and watch things break (and heal).

## Your Environment

- 2-node Kubernetes cluster (`controlplane` + `node01`)
- `krknctl` is being installed in the background right now
- Scenario container images are pre-pulling to save you time

**Click START to begin!**
