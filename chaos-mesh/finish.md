# Congratulations! You've Mastered Kubernetes-Native Chaos

## What You Accomplished

In about 20 minutes you ran the full Chaos Mesh workflow on a real cluster:

### Step 1: Installed the Platform
- Deployed Chaos Mesh with Helm, wired to containerd, and met its architecture: controller-manager (reconciles CRDs) + chaos-daemon (injects faults per node)

### Step 2: Chaos as Code
- Killed a pod with a `PodChaos` resource and watched the ReplicaSet heal - then inspected the experiment's audit trail with `kubectl describe`

### Step 3: Degradation, Not Just Destruction
- Injected 200ms latency with `NetworkChaos`, **measured** the impact live, and reverted it instantly by deleting the resource

### Step 4: The Dashboard
- Drove the same engine from the web UI and saw that UI experiments are just CRDs

### Step 5: Chaos Campaigns
- Composed a serial `Workflow` - pod kill, then network delay - all in one declarative, git-committable YAML

## The Chaos Mesh Idea in One Line

> **Failures are Kubernetes resources**: declared with YAML, scoped by selectors and RBAC, reverted by deletion, audited by events, and composed into workflows.

## What Else Is in the Toolbox

| Fault type | What it simulates |
|------------|-------------------------------------------|
| `StressChaos` | CPU/memory pressure inside containers |
| `IOChaos` | Slow or failing disk I/O |
| `HTTPChaos` | Intercept/abort/delay HTTP requests |
| `DNSChaos` | Wrong or failing DNS answers |
| `TimeChaos` | Clock skew inside containers |
| `Schedule` | Any fault, on a cron |
| `StatusCheck` | Auto-abort campaigns when SLOs break |

## Keep Going

| Resource | Link |
|----------|------|
| Chaos Mesh docs | [chaos-mesh.org/docs](https://chaos-mesh.org/docs/) |
| GitHub (star it!) | [github.com/chaos-mesh/chaos-mesh](https://github.com/chaos-mesh/chaos-mesh) |
| CNCF project page | [cncf.io/projects/chaosmesh](https://www.cncf.io/projects/chaosmesh/) |
| Slack | [#project-chaos-mesh on CNCF Slack](https://cloud-native.slack.com/archives/C0193VAV272) |

## Compare the Approaches

Curious how CLI-driven chaos feels in contrast? Try the companion scenario: **[Getting Started with Krkn](https://killercoda.com/saiyampathak/scenario/krkn)** - same cluster, same 20 minutes, a completely different philosophy (external runner + exit codes for CI/CD instead of in-cluster CRDs).

**Now go break things on purpose - declaratively!**
