# Deploy Ollama and Verify CPU Operation

Now let's deploy Ollama on our Kubernetes cluster. Ollama is perfect for our environment because it works on any CPU without requiring special instruction sets like AVX2 or AVX-512.

## Understanding Ollama

Ollama is a lightweight tool for running large language models:
- **Universal CPU Support**: Works on any CPU (no AVX2/AVX-512 required)
- **Easy to Use**: Simple REST API and CLI
- **Model Variety**: Supports many open-source models (Llama, Mistral, TinyLlama, etc.)
- **Lightweight**: Optimized for resource-constrained environments
- **Production Ready**: Used in many Kubernetes deployments

**Note**: While llm-d uses vLLM (which requires AVX2+ CPUs), Ollama provides a more compatible solution for environments like Killercoda that may not have advanced CPU instruction sets.

## Deploy Ollama

Let's create the Ollama deployment manifest:

```bash
# Create the Ollama deployment manifest
cat <<EOF > /root/workspace/llm-workshop/ollama-deployment.yaml
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
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        env:
        # Use basic CPU mode for maximum compatibility (no AVX2 required)
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
kubectl apply -f /root/workspace/llm-workshop/ollama-deployment.yaml
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

## Verify CPU Operation

Let's verify that Ollama is running on CPU:

```bash
# Check the pod details
kubectl describe pod -l app=ollama-server -n llm-workshop | grep -A 5 "Limits\|Requests"

# Check pod status
kubectl get pods -n llm-workshop -o wide

# Check pod logs
kubectl logs -l app=ollama-server -n llm-workshop --tail=10
```{{exec}}

## Test Ollama API

Let's test that Ollama is responding:

```bash
# Check Ollama version
kubectl exec deployment/ollama-server -n llm-workshop -- ollama --version

# List available models (should be empty initially)
kubectl exec deployment/ollama-server -n llm-workshop -- ollama list
```{{exec}}

## Understanding CPU Modes

**Ollama CPU Modes**:
- `cpu` - Basic mode, works on ANY CPU (no AVX required)
- `cpu_avx` - Faster, requires AVX instructions
- `cpu_avx2` - Fastest CPU mode, requires AVX2 instructions

We're using `OLLAMA_LLM_LIBRARY="cpu"` for maximum compatibility.

**Why Ollama instead of vLLM/llm-d?**
- llm-d CPU image requires AVX2 instruction sets
- Killercoda's environment doesn't have AVX2
- Ollama works on any CPU with its fallback mode
- Same concepts apply: containerized LLM serving on Kubernetes

**For production with modern CPUs**, consider:
- **llm-d** (`ghcr.io/llm-d/llm-d-cpu`) - Kubernetes-native, requires AVX2+
- **vLLM** - High performance, requires AVX512 for best results

## Ollama Deployment Summary

We've successfully:
- ✅ Deployed Ollama on Kubernetes
- ✅ Created a service to expose Ollama internally
- ✅ Configured CPU-only mode for maximum compatibility
- ✅ Confirmed the pod is ready and healthy

## What's Next?

In the next step, we'll pull a lightweight model and test it!

---

**Ollama running?** Let's load a model! 🚀
