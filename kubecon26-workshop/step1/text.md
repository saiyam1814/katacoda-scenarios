# Step 1: Deploy Your AI Infrastructure on Kubernetes

In this step, you'll deploy **Ollama** - an LLM inference server - on Kubernetes. This is the exact same pattern used in production, just without the GPU (for now).

## The GPU Stack (What Happens in Production)

In a production GPU environment, when you deploy an AI workload on Kubernetes, here's what happens under the hood:

```
┌─────────────────────────────────────────────┐
│  Your Pod (requests: nvidia.com/gpu: 1)     │  <-- You define this
├─────────────────────────────────────────────┤
│  Kubernetes Scheduler                        │  <-- Finds a GPU node
├─────────────────────────────────────────────┤
│  NVIDIA Device Plugin                        │  <-- Allocates GPU to pod
├─────────────────────────────────────────────┤
│  NVIDIA Container Toolkit                    │  <-- Mounts /dev/nvidia0
├─────────────────────────────────────────────┤
│  NVIDIA GPU Driver                           │  <-- Talks to hardware
├─────────────────────────────────────────────┤
│  Physical GPU (A100/H100/L4/T4)             │  <-- The actual silicon
└─────────────────────────────────────────────┘
```

The **NVIDIA GPU Operator** automates installing all these layers. Today, we're deploying on CPU, but the Kubernetes patterns are identical.

## Verify Your Cluster

Let's make sure our Kubernetes cluster is ready:

```bash
kubectl get nodes -o wide
```{{exec}}

You should see 2 nodes in `Ready` status.

## Check Workshop Namespace

The background script already created our namespace. Let's verify:

```bash
kubectl get namespace ai-workshop
kubectl config view --minify | grep namespace
```{{exec}}

## Deploy Ollama

Now let's deploy the Ollama inference server. Study the YAML carefully - notice the **resource requests and limits**. In production, you'd also add `nvidia.com/gpu: 1` under resources.

```bash
cat <<'EOF' > /root/workshop/manifests/ollama-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: ai-workshop
  labels:
    app: ollama
    component: inference-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
        component: inference-server
    spec:
      containers:
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
          name: http
          protocol: TCP
        env:
        # CPU mode for maximum compatibility
        # In production: remove this to auto-detect GPU
        - name: OLLAMA_LLM_LIBRARY
          value: "cpu"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
            # Production GPU: nvidia.com/gpu: 1
          limits:
            memory: "2Gi"
            cpu: "1000m"
            # Production GPU: nvidia.com/gpu: 1
        readinessProbe:
          httpGet:
            path: /
            port: http
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: http
          initialDelaySeconds: 10
          periodSeconds: 30
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
  namespace: ai-workshop
  labels:
    app: ollama
spec:
  selector:
    app: ollama
  ports:
  - port: 11434
    targetPort: http
    name: http
  type: ClusterIP
EOF

kubectl apply -f /root/workshop/manifests/ollama-deployment.yaml
```{{exec}}

## Wait for Ollama to be Ready

```bash
echo "Waiting for Ollama pod to be ready..."
kubectl wait --for=condition=ready pod -l app=ollama -n ai-workshop --timeout=120s
```{{exec}}

## Verify the Deployment

Let's inspect what Kubernetes created for us:

```bash
echo "=== Pod Status ==="
kubectl get pods -n ai-workshop -o wide

echo ""
echo "=== Service ==="
kubectl get svc -n ai-workshop

echo ""
echo "=== Resource Allocation ==="
kubectl describe pod -l app=ollama -n ai-workshop | grep -A 5 "Limits\|Requests"
```{{exec}}

## Test Ollama API

Let's verify Ollama is responding to API requests:

```bash
# Check Ollama version
kubectl exec deployment/ollama -n ai-workshop -- ollama --version

# List models (should be empty - we haven't pulled any yet)
kubectl exec deployment/ollama -n ai-workshop -- ollama list
```{{exec}}

## What Just Happened?

Let's break down what Kubernetes did when you ran `kubectl apply`:

1. **API Server** received the Deployment manifest
2. **Scheduler** found a node with enough CPU/memory
3. **Kubelet** on that node pulled the `ollama/ollama` image
4. **Container runtime** (containerd) started the container
5. **Readiness probe** confirmed Ollama is healthy
6. **Service** created a stable DNS name: `ollama.ai-workshop.svc.cluster.local`

> **Production Note**: With a GPU, steps 2-4 would also involve the Device Plugin allocating a GPU and the Container Toolkit mounting the GPU device into the container. The NVIDIA GPU Operator handles installing all of this automatically.

## GPU Sharing Preview

In the slides, you learned about GPU sharing. Here's how it maps to Kubernetes:

```yaml
# Time-Slicing: Multiple pods share one GPU
# Set via NVIDIA device plugin ConfigMap
resources:
  limits:
    nvidia.com/gpu: 1  # Gets time-sliced access

# MIG: Hardware-partitioned GPU instances
resources:
  limits:
    nvidia.com/mig-3g.40gb: 1  # Gets a dedicated MIG slice

# MPS: Concurrent GPU access
# Configured via GPU Operator MPS daemon
resources:
  limits:
    nvidia.com/gpu: 1  # Gets concurrent access via MPS
```

We'll explore vCluster multi-tenancy (which pairs beautifully with MIG) in Step 5!

## Step Summary

You've successfully deployed an LLM inference server on Kubernetes:

- Ollama deployment with health probes and resource management
- ClusterIP service for internal access
- Same deployment pattern used for GPU workloads in production
- Understanding of the full GPU stack (driver -> plugin -> runtime -> pod)

**Next: Let's pull a model and start chatting with AI!**
