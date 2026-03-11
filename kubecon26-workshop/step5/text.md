# Step 5: Multi-Tenant AI with vCluster

You've built a complete AI pipeline. But in a real organization, **multiple teams** need their own AI environments - ML engineers for training, data scientists for experimentation, product teams for inference. They need **isolation** without the cost of separate clusters.

This is exactly what Artem showed with the **vCluster Platform Blueprint** - and now you'll build it yourself.

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

## Deploy Ollama Inside the vCluster

Now deploy AI infrastructure inside the virtual cluster - team-ml gets their own isolated AI environment:

```bash
# Create team-ml's AI namespace
kubectl create namespace ai-inference

# Deploy Ollama inside the vCluster
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: ai-inference
  labels:
    app: ollama
    team: ml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
        team: ml
    spec:
      containers:
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        env:
        - name: OLLAMA_LLM_LIBRARY
          value: "cpu"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: model-storage
          mountPath: /root/.ollama
      volumes:
      - name: model-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: ollama
  namespace: ai-inference
spec:
  selector:
    app: ollama
  ports:
  - port: 11434
    targetPort: 11434
  type: ClusterIP
EOF

echo "Deployed Ollama in team-ml's vCluster!"
```{{exec}}

## Wait for Ollama and Pull Model

```bash
echo "Waiting for Ollama in vCluster..."
kubectl wait --for=condition=ready pod -l app=ollama -n ai-inference --timeout=180s

echo ""
echo "Pulling TinyLlama model..."
kubectl exec -it deployment/ollama -n ai-inference -- ollama pull tinyllama
```{{exec}}

## Test AI Inside the vCluster

```bash
# Team ML can use their isolated AI environment
echo "What is a virtual cluster and why is it useful for AI workloads?" | \
  kubectl exec -i deployment/ollama -n ai-inference -- ollama run tinyllama
```{{exec}}

## See the Isolation

Let's look at what the **host cluster** sees vs what the **vCluster** sees:

```bash
echo "=== Inside vCluster (team-ml's view) ==="
echo "Namespaces:"
kubectl get namespaces
echo ""
echo "Pods in ai-inference:"
kubectl get pods -n ai-inference -o wide

echo ""
echo "=== Team-ml thinks they have their own cluster! ==="
echo "They can create namespaces, deploy anything, set RBAC -"
echo "all without affecting other teams or the host cluster."
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
echo "Namespaces (host sees vCluster as a namespace):"
kubectl get namespaces
echo ""
echo "What's in the team-ml namespace (host perspective):"
kubectl get pods -n team-ml
echo ""
echo "The host only sees vCluster infrastructure -"
echo "NOT the team's internal namespaces or workloads directly."
```{{exec}}

## How This Maps to Artem's Platform Blueprint

What you just built manually is what the **vCluster Platform** automates at scale:

```
┌──────────────────────────────────────────────────────────────┐
│  What Artem Showed (Platform)     What You Built (Manual)    │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  vCluster Platform UI/CLI    →    vcluster create team-ml    │
│  Self-service portal         →    kubectl inside vCluster    │
│  Auto Nodes + Karpenter      →    (simulated with CPU)       │
│  GPU Operator + MIG           →    (CPU mode)                │
│  Sleep mode / cost control   →    (not configured here)      │
│  Resource quotas per team    →    limits in pod spec         │
│  RBAC templates               →    manual RBAC               │
│                                                               │
│  In production with GPU:                                     │
│  - team-ml gets MIG 3g.40gb instances                       │
│  - team-data gets dedicated A100 via Auto Nodes              │
│  - dev-sandbox gets CPU-only with sleep after 30min         │
│  - Platform team manages the host, teams manage vClusters   │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## The Production Pattern: vCluster + GPU Sharing

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
- Deployed a complete AI stack (Ollama + TinyLlama) inside the vCluster
- Demonstrated full isolation: team has their own API server, namespaces, RBAC
- Connected the dots to Artem's Platform Blueprint and GPU sharing
- Understood how vCluster + MIG/Auto Nodes = production multi-tenant AI

**You've built a complete AI platform on Kubernetes!**
