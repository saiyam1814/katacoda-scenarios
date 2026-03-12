# Step 5: Multi-Tenant AI with vCluster

You've built a complete AI pipeline. But in a real organization, **multiple teams** need their own AI environments - ML engineers for training, data scientists for experimentation, product teams for inference. They need **isolation** without the cost of separate clusters.

This is exactly what Artem showed with the **vCluster Platform Blueprint** - and now you'll build it yourself.

![Multi-Tenant AI with vCluster](https://raw.githubusercontent.com/saiyam1814/katacoda-scenarios/main/kubecon26-workshop/images/vcluster-multi-tenant.png)

## The Multi-Tenancy Problem

```
Without vCluster:                    With vCluster:
┌──────────────────────────┐        ┌──────────────────────────┐
│  Shared Namespace         │        │  Host Cluster             │
│  ┌────────┐ ┌────────┐  │        │  ┌──────────────────┐    │
│  │Team A  │ │Team B  │  │        │  │ vCluster: team-a │    │
│  │Ollama  │ │Ollama  │  │        │  │ Own API server   │    │
│  └────────┘ └────────┘  │        │  │ Own namespaces   │    │
│  - Can see each other    │        │  │ Full isolation    │    │
│  - Shared RBAC headaches │        │  └──────────────────┘    │
│  - Resource conflicts    │        │  ┌──────────────────┐    │
│  - No real isolation     │        │  │ vCluster: team-b │    │
└──────────────────────────┘        │  │ Own API server   │    │
                                     │  │ Own namespaces   │    │
                                     │  │ Full isolation    │    │
                                     │  └──────────────────┘    │
                                     └──────────────────────────┘
```

Each vCluster gets its own Kubernetes API server, its own namespaces, its own RBAC - but shares the underlying physical nodes and resources.

## First: Free Up Resources

Our environment has limited memory. Let's clean up the previous workload to make room for vCluster:

```bash
# Stop the port-forward
kill %1 2>/dev/null

# Delete the current Ollama deployment to free memory
kubectl delete deployment ollama -n ai-workshop
kubectl delete svc ollama -n ai-workshop

echo "Resources freed. Waiting for pod termination..."
sleep 5
kubectl get pods -n ai-workshop
```{{exec}}

## Verify vCluster CLI

The background script pre-installed the vCluster CLI:

```bash
vcluster --version
```{{exec}}

## Create a vCluster for Team ML

Let's create an isolated virtual cluster for a machine learning team:

```bash
# Create vCluster named "team-ml" in the "team-ml" namespace
vcluster create team-ml --namespace team-ml --connect=false
```{{exec}}

## Wait for vCluster to be Ready

```bash
echo "Waiting for vCluster to be ready..."
kubectl get pods -n team-ml -w &
WATCH_PID=$!
sleep 30
kill $WATCH_PID 2>/dev/null

# Check final status
echo ""
echo "=== vCluster Status ==="
vcluster list
```{{exec}}

## Connect to the vCluster

```bash
# Connect to the vCluster (this switches your kubectl context)
vcluster connect team-ml --namespace team-ml
```{{exec}}

## Explore the Virtual Cluster

You're now inside a virtual Kubernetes cluster. It looks like a real cluster:

```bash
echo "=== Nodes (virtual view) ==="
kubectl get nodes

echo ""
echo "=== Namespaces ==="
kubectl get namespaces

echo ""
echo "=== This is team-ml's own cluster! ==="
echo "They have full admin access here without affecting other teams."
```{{exec}}

## Deploy a Workload Inside the vCluster

Now deploy infrastructure inside the virtual cluster. We'll deploy a lightweight nginx web server to demonstrate isolation (Ollama + model would exceed the memory limits of this lab environment):

```bash
# Create team-ml's namespaces - they have FULL control
kubectl create namespace ai-inference
kubectl create namespace monitoring

# Deploy a workload inside the vCluster
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-api
  namespace: ai-inference
  labels:
    app: model-api
    team: ml
spec:
  replicas: 2
  selector:
    matchLabels:
      app: model-api
  template:
    metadata:
      labels:
        app: model-api
        team: ml
    spec:
      containers:
      - name: api
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "32Mi"
            cpu: "50m"
          limits:
            memory: "64Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: model-api
  namespace: ai-inference
spec:
  selector:
    app: model-api
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo "Deployed workload in team-ml's vCluster!"
```{{exec}}

## Wait for Deployment

```bash
echo "Waiting for pods in vCluster..."
kubectl wait --for=condition=ready pod -l app=model-api -n ai-inference --timeout=120s

echo ""
echo "=== Pods running in team-ml's vCluster ==="
kubectl get pods -n ai-inference -o wide
```{{exec}}

> **Note**: In this lab we deployed nginx to demonstrate isolation without exhausting resources. In production with real GPUs, this is where you'd deploy Ollama/vLLM with `nvidia.com/gpu: 1` in the resource requests, and each team's vCluster would have access to their allocated MIG slices or dedicated GPUs via Auto Nodes.

## See the Isolation

Let's look at what **team-ml sees** inside their vCluster:

```bash
echo "=== Inside vCluster (team-ml's view) ==="
echo ""
echo "Namespaces (team created these themselves):"
kubectl get namespaces
echo ""
echo "Pods in ai-inference:"
kubectl get pods -n ai-inference -o wide
echo ""
echo "Services:"
kubectl get svc -n ai-inference
echo ""
echo "Team-ml has FULL admin access here."
echo "They can create namespaces, RBAC, CRDs - anything."
echo "But they CANNOT see or affect other teams' vClusters."
```{{exec}}

## Disconnect and See Host View

```bash
# Disconnect from vCluster (back to host context)
vcluster disconnect
```{{exec}}

```bash
# Now see what the HOST cluster sees
echo "=== Host Cluster View ==="
echo ""
echo "Namespaces on host (vCluster lives in team-ml namespace):"
kubectl get namespaces
echo ""
echo "What the host sees in team-ml namespace:"
kubectl get pods -n team-ml
echo ""
echo "Notice: The host sees vCluster infrastructure pods."
echo "It does NOT see team-ml's internal 'ai-inference' namespace"
echo "or their model-api pods directly. Full isolation!"
```{{exec}}

## The Production Pattern: vCluster + GPU Sharing

![Production Architecture](https://raw.githubusercontent.com/saiyam1814/katacoda-scenarios/main/kubecon26-workshop/images/production-architecture.png)

In production, the **vCluster Platform** automates everything you just did manually - self-service portals, RBAC templates, sleep mode, cost allocation, and Auto Nodes that dynamically provision GPU hardware.

In a real deployment, vCluster pairs with GPU sharing like this:

```yaml
# Platform admin creates a vCluster with GPU access
# The vCluster's pods can request GPU resources from the host

# Team ML's pod (inside their vCluster):
resources:
  limits:
    nvidia.com/mig-3g.40gb: 1  # Gets a MIG slice of the A100

# Team Data's pod (inside their vCluster):
resources:
  limits:
    nvidia.com/gpu: 2  # Gets 2 full GPUs via Auto Nodes

# Dev Sandbox (inside their vCluster):
resources:
  limits:
    cpu: "2"  # CPU only, no GPU budget
```

The **vCluster Platform** enforces quotas so team-ml can't use more GPUs than allocated, and Auto Nodes dynamically provision GPU hardware only when workloads need it.

## Step Summary

- Created an isolated virtual Kubernetes cluster using vCluster
- Deployed workloads inside the vCluster with full admin access
- Demonstrated full isolation: team has their own API server, namespaces, RBAC
- Host cluster only sees vCluster infrastructure, not internal resources
- In production: each vCluster gets GPU access via MIG + Auto Nodes

**You've built a complete AI platform on Kubernetes - from LLM deployment to RAG to multi-tenancy!**
