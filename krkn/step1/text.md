# Step 1: Meet Your Cluster and Deploy a Target App

Before we break anything, we need something to break. In this step you'll verify the cluster and deploy a target application that Krkn will attack in the next steps.

## Verify Your Cluster

You have a real 2-node Kubernetes cluster:

```bash
kubectl get nodes -o wide
```{{exec}}

Both `controlplane` and `node01` should be `Ready`.

## Deploy the Target Application

Let's deploy an nginx application with **3 replicas** into the `demo` namespace. The replica count matters: it's what gives Kubernetes room to self-heal when chaos strikes.

```bash
kubectl create deployment nginx --image=nginx --replicas=3 -n demo
kubectl expose deployment nginx --port=80 -n demo
```{{exec}}

Wait for all replicas to come up:

```bash
kubectl rollout status deployment/nginx -n demo --timeout=120s
kubectl get pods -n demo -o wide --show-labels
```{{exec}}

Note two things in the output:

1. **The label** `app=nginx` - Krkn targets pods by label, exactly like a Service or NetworkPolicy would.
2. **The node column** - pods are spread across your nodes.

## How Krkn Thinks About Chaos

A Krkn chaos experiment follows a simple loop:

```
  +-----------+     +-----------+     +--------------+
  |  TARGET   | --> |  DISRUPT  | --> |   VERIFY     |
  | (by label,|     | (kill pod,|     | (did it      |
  |  ns, node)|     |  hog CPU) |     |  recover?)   |
  +-----------+     +-----------+     +--------------+
```

That last box is the important one: Krkn doesn't just cause failures, it **checks that your system recovered within a timeout** and reports pass/fail. That's what makes it a resilience *testing* tool rather than just a wrecking ball.

## Check the Chaos Tooling

The background setup installed `krknctl`, the Krkn CLI. Confirm it's ready:

```bash
krknctl --help | head -20
```{{exec}}

> **Note:** If the command isn't found yet, the background install is still running. Give it a moment and re-run the command.

Your target is deployed. Time to unleash the kraken.
