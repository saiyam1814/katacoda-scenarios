# Deploying vLLM on Kubernetes

Now let's deploy vLLM on our Kubernetes cluster. vLLM is perfect for our CPU-based environment as it's specifically optimized for high-performance LLM inference.

## Understanding vLLM

vLLM is a high-throughput and memory-efficient inference and serving engine for LLMs. It:
- **High Performance**: Optimized for both GPU and CPU inference
- **Memory Efficient**: Advanced memory management and caching
- **OpenAI Compatible**: Drop-in replacement for OpenAI API
- **CPU Optimized**: Excellent support for CPU-based inference
- **Production Ready**: Used by many companies in production

## Deploy vLLM

Let's create the vLLM deployment manifest and deploy it:

```bash
# Create the vLLM deployment manifest
cat <<EOF > /home/vllm-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-server
  namespace: llm-workshop
  labels:
    app: vllm-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm-server
  template:
    metadata:
      labels:
        app: vllm-server
    spec:
      containers:
      - name: vllm-server
        image: vllm/vllm-cpu:latest
        ports:
        - containerPort: 8000
        env:
        - name: VLLM_CPU_KVCACHE_SPACE
          value: "2"
        - name: VLLM_CPU_OMP_THREADS_BIND
          value: "auto"
        - name: VLLM_CPU_NUM_OF_RESERVED_CPU
          value: "1"
        command: ["python", "-m", "vllm.entrypoints.openai.api_server"]
        args: [
          "--model", "facebook/opt-125m",
          "--dtype", "bfloat16",
          "--host", "0.0.0.0",
          "--port", "8000",
          "--max-num-seqs", "32",
          "--max-num-batched-tokens", "2048"
        ]
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        securityContext:
          seccompProfile:
            type: Unconfined
          capabilities:
            add:
            - SYS_NICE
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: vllm-service
  namespace: llm-workshop
spec:
  selector:
    app: vllm-server
  ports:
  - port: 8000
    targetPort: 8000
  type: ClusterIP
EOF

# Deploy vLLM
kubectl apply -f /home/vllm-deployment.yaml
```{{exec}}

## Wait for Deployment

Let's wait for the vLLM pod to be ready:

```bash
kubectl wait --for=condition=ready pod -l app=vllm-server -n llm-workshop --timeout=300s
```{{exec}}

## Verify vLLM is Running

Check that vLLM is running correctly:

```bash
kubectl get pods -n llm-workshop
kubectl get svc -n llm-workshop
```{{exec}}

## Create a Port Forward

For easier access, let's create a port forward:

```bash
kubectl port-forward svc/vllm-service 8000:8000 -n llm-workshop &
```{{exec}}

## Test vLLM API

Let's test the vLLM API (OpenAI compatible):

```bash
# Test the health endpoint
curl http://localhost:8000/health

# Test the models endpoint
curl http://localhost:8000/v1/models

# Test a simple completion
curl -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "Hello! Can you tell me about Kubernetes?",
    "max_tokens": 100
  }'
```

## vLLM Deployment Summary

We've successfully:
- ✅ Deployed vLLM on Kubernetes with CPU optimization
- ✅ Created a service to expose vLLM
- ✅ Configured vLLM for CPU inference with proper settings
- ✅ Tested the OpenAI-compatible API
- ✅ Set up port forwarding for easy access

## What's Next?

In the next step, we'll explore more advanced features of our LLM deployment and create a simple web interface!

---

**vLLM running?** Let's build something amazing! 🚀
