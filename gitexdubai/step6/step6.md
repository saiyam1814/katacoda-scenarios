# Multi-tenancy with vcluster

Now let's explore multi-tenancy using vcluster, which allows us to create virtual Kubernetes clusters on top of our existing cluster. This is perfect for isolating different teams and workloads.

## Understanding vcluster

vcluster (Virtual Cluster) provides:
- **Isolation**: Each team gets their own virtual cluster
- **Resource Efficiency**: Share underlying cluster resources
- **Cost Optimization**: Reduce infrastructure costs
- **Security**: Strong workload isolation
- **Simplicity**: Teams see a standard Kubernetes cluster

## Create Team A vcluster

Let's create a virtual cluster for Team A:

```bash
# Create vcluster for Team A
vcluster create team-a --namespace llm-workshop --create-namespace --kubernetes-version v1.28.0 --resource-quota="requests.cpu=1,requests.memory=1Gi,limits.cpu=2,limits.memory=2Gi"

# Wait for vcluster to be ready
kubectl wait --for=condition=ready pod -l app=vcluster -n llm-workshop --timeout=120s
```

## Connect to Team A vcluster

```bash
# Get kubeconfig for Team A vcluster
vcluster connect team-a --namespace llm-workshop --kube-config /root/.kube/config-team-a

# Set context for Team A
export KUBECONFIG=/root/.kube/config-team-a
kubectl config use-context team-a

# Verify we're connected to Team A vcluster
kubectl get nodes
kubectl get pods --all-namespaces
```

## Deploy Ollama in Team A vcluster

```bash
# Create namespace for Team A
kubectl create namespace team-a-llm

# Deploy a simple LLM service in Team A vcluster
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llm-service-team-a
  namespace: team-a-llm
  labels:
    app: llm-service-team-a
spec:
  replicas: 1
  selector:
    matchLabels:
      app: llm-service-team-a
  template:
    metadata:
      labels:
        app: llm-service-team-a
    spec:
      containers:
      - name: llm-service
        image: python:3.9-slim
        ports:
        - containerPort: 8000
        command: ["/bin/bash"]
        args: ["-c", "pip install flask requests && python /app/llm_service.py"]
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "200m"
        volumeMounts:
        - name: app-code
          mountPath: /app
      volumes:
      - name: app-code
        configMap:
          name: llm-service-code
EOF
```

## Create Team B vcluster

Now let's create a virtual cluster for Team B:

```bash
# Switch back to host cluster
export KUBECONFIG=/root/.kube/config
kubectl config use-context kubernetes-admin@kubernetes

# Create vcluster for Team B
vcluster create team-b --namespace llm-workshop --create-namespace --kubernetes-version v1.28.0 --resource-quota="requests.cpu=1,requests.memory=1Gi,limits.cpu=2,limits.memory=2Gi"

# Wait for vcluster to be ready
kubectl wait --for=condition=ready pod -l app=vcluster -n llm-workshop --timeout=120s
```

## Test Multi-tenancy

Let's verify that both teams have isolated environments:

```bash
# Check vclusters
kubectl get vclusters -n llm-workshop

# Check Team A resources
export KUBECONFIG=/root/.kube/config-team-a
kubectl get pods --all-namespaces

# Check Team B resources
export KUBECONFIG=/root/.kube/config-team-b
kubectl get pods --all-namespaces
```

## Multi-tenancy Summary

We've successfully implemented:
- ✅ Two isolated virtual clusters using vcluster
- ✅ Team A with LLM service
- ✅ Team B with separate workload
- ✅ Resource quotas and isolation
- ✅ Independent team workflows

## What's Next?

In the next step, we'll explore scaling and optimization strategies for our LLM workloads!

---

**Multi-tenancy working?** Let's scale and optimize! 🚀
