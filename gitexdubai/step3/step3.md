# Deploying Ollama on Kubernetes

Now let's deploy Ollama on our Kubernetes cluster. Ollama is perfect for our CPU-based environment as it's lightweight and works reliably without special instruction sets.

## Understanding Ollama

Ollama is a tool that makes it easy to run large language models locally. It:
- **Lightweight**: Works on any CPU without special instruction sets
- **Easy to Use**: Simple command-line interface
- **Model Variety**: Supports many open-source models
- **Local First**: Runs models locally without external dependencies
- **CPU Optimized**: Designed to work well on CPU-only environments

## Deploy Ollama

Let's create the Ollama deployment manifest and deploy it:

```bash
# Create the Ollama deployment manifest
cat <<EOF > /home/ollama-deployment.yaml
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

# Deploy Ollama
kubectl apply -f /home/ollama-deployment.yaml
```{{exec}}

## Wait for Deployment

Let's wait for the Ollama pod to be ready:

```bash
kubectl wait --for=condition=ready pod -l app=ollama-server -n llm-workshop --timeout=300s
```{{exec}}

## Verify Ollama is Running

Check that Ollama is running correctly:

```bash
kubectl get pods -n llm-workshop
kubectl get svc -n llm-workshop
```{{exec}}

## Create a Port Forward

For easier access, let's create a port forward:

```bash
kubectl port-forward svc/ollama-service 11434:11434 -n llm-workshop &
```{{exec}}

## Install a Lightweight Model

Let's install a lightweight model suitable for our CPU environment:

```bash
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama pull llama3.2:1b
```{{exec}}

## Test Ollama API

Let's test the Ollama API:

```bash
# Test a simple completion
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama run llama3.2:1b "Hello! Can you tell me about Kubernetes?"
```{{exec}}

## Ollama Deployment Summary

We've successfully:
- ✅ Deployed Ollama on Kubernetes with minimal resource requirements
- ✅ Created a service to expose Ollama
- ✅ Installed a lightweight 1B parameter model
- ✅ Tested the Ollama API
- ✅ Set up port forwarding for easy access

## What's Next?

In the next step, we'll create a simple web interface to interact with our Ollama model!

---

**Ollama running?** Let's build something amazing! 🚀
