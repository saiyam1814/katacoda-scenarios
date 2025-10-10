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

First, let's copy the manifest files to the home directory and then deploy vLLM:

```bash
# Copy the manifest files to /home
cp /tmp/repo/git/gitexdubai/vllm-deployment.yaml /home/
cp /tmp/repo/git/gitexdubai/rag-app-deployment.yaml /home/
cp /tmp/repo/git/gitexdubai/hpa.yaml /home/

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
