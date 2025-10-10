# Multi-tenancy with vcluster

Now let's explore multi-tenancy using vcluster, which allows us to create virtual Kubernetes clusters on top of our existing cluster. This is perfect for isolating different teams and workloads.

## Understanding vcluster

vcluster (Virtual Cluster) provides:
- **Isolation**: Each team gets their own virtual cluster
- **Resource Efficiency**: Share underlying cluster resources
- **Cost Optimization**: Reduce infrastructure costs
- **Security**: Strong workload isolation
- **Simplicity**: Teams see a standard Kubernetes cluster

## Switch to Default Namespace and Clean Up

First, let's switch back to the default namespace and clean up resources:

```bash
# Switch to default namespace
kubectl config set-context --current --namespace=default

# Delete the workshop namespace to free resources
kubectl delete namespace llm-workshop
```{{exec}}

## Create a Simple vcluster

Let's create a single vcluster for our workshop:

```bash
# Create vcluster for the workshop
vcluster create workshop-cluster --namespace default --create-namespace --kubernetes-version v1.28.0

# Wait for vcluster to be ready
kubectl wait --for=condition=ready pod -l app=vcluster -n default --timeout=120s
```{{exec}}

## Connect to Workshop vcluster

```bash
# Get kubeconfig for workshop vcluster
vcluster connect workshop-cluster --namespace default --kube-config /root/.kube/config-workshop

# Switch to workshop context
export KUBECONFIG=/root/.kube/config-workshop
kubectl config use-context workshop-cluster

# Verify we're connected to workshop vcluster
kubectl get nodes
kubectl get pods --all-namespaces
```{{exec}}

## Deploy Ollama in vcluster

Now let's deploy Ollama in our virtual cluster:

```bash
# Create namespace for our LLM workload
kubectl create namespace llm-workshop

# Deploy Ollama in the vcluster
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama-server
  namespace: llm-workshop
  labels:
    app: ollama-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama-server
  template:
    metadata:
      labels:
        app: ollama-server
    spec:
      containers:
      - name: ollama-server
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: ollama-data
          mountPath: /root/.ollama
      volumes:
      - name: ollama-data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: ollama-service
  namespace: llm-workshop
spec:
  selector:
    app: ollama-server
  ports:
  - port: 11434
    targetPort: 11434
  type: ClusterIP
EOF
```{{exec}}

## Install TinyLlama in vcluster

```bash
# Wait for Ollama to be ready
kubectl wait --for=condition=ready pod -l app=ollama-server -n llm-workshop --timeout=300s

# Install TinyLlama model
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama pull tinyllama
```{{exec}}

## Test the vcluster Setup

```bash
# Test the model in vcluster
echo "What is Kubernetes?" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama

# Check resource usage
kubectl top pods -n llm-workshop
```{{exec}}

## vcluster Summary

We've successfully:
- ✅ Created a virtual cluster using vcluster
- ✅ Deployed Ollama with TinyLlama in the vcluster
- ✅ Demonstrated multi-tenancy isolation
- ✅ Tested the setup works correctly

## What's Next?

In the next step, we'll explore scaling and optimization strategies for our LLM workloads!

---

**vcluster working?** Let's scale it up! 🚀