# Chaos Engineering with Chaos Mesh

## Chaos, the Kubernetes-Native Way

**Chaos Mesh** is a [CNCF incubating](https://www.cncf.io/projects/chaosmesh/) chaos engineering platform for Kubernetes. Its superpower: chaos experiments are **Kubernetes custom resources**. You `kubectl apply` a fault the same way you apply a Deployment - and manage it with the same GitOps, RBAC, and tooling you already use.

## What You'll Do in ~20 Minutes

```
Step 1: Install Chaos Mesh with Helm and deploy a target app
Step 2: Kill pods with a PodChaos resource - chaos as YAML
Step 3: Inject 200ms network latency and measure it live
Step 4: Explore experiments in the Chaos Mesh web dashboard
Step 5: Chain experiments into a serial chaos Workflow
```

## How Chaos Mesh Works

```
  kubectl / Dashboard / GitOps
            |
            v
  +---------------------+     watches CRDs
  | chaos-controller-   | <------------------+
  | manager             |                    |
  +----------+----------+          PodChaos, NetworkChaos,
             |                     StressChaos, Workflow...
             v
  +---------------------+
  | chaos-daemon        |  DaemonSet on every node:
  | (privileged)        |  enters target containers'
  +---------------------+  namespaces to inject faults
```

- **CRDs** define *what* to break: `PodChaos`, `NetworkChaos`, `IOChaos`, `StressChaos`, `TimeChaos`, `HTTPChaos`, and more
- **chaos-controller-manager** schedules and reconciles experiments
- **chaos-daemon** runs on each node and injects the actual faults (kill processes, add `tc netem` rules, stress CPU) inside target containers
- **Dashboard** gives you a full web UI to create, observe, and archive experiments

## Your Environment

- 2-node Kubernetes cluster (`controlplane` + `node01`) with containerd
- Helm is ready and the Chaos Mesh chart repo is added
- Container images are pre-pulling in the background to save you time

**Click START to begin!**
