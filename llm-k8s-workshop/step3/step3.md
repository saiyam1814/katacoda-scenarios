# Run the Smallest LLM Model

Now let's test our vLLM deployment with the smallest model - OPT-125M. This model is already loaded in our deployment and is perfect for our CPU-based environment as it's lightweight and fast.

## Understanding OPT-125M

**OPT-125M** (Open Pre-trained Transformer) is:
- **Ultra Lightweight**: Only 125 million parameters (~250MB)
- **Fast**: Quick inference times with vLLM optimization
- **Capable**: Good performance for many tasks despite small size
- **Open Source**: Released by Meta (Facebook)
- **Memory Efficient**: Designed to work in low-memory environments
- **CPU Optimized**: Works well with vLLM's CPU backend

## Verify Model is Loaded

Let's check that the model is loaded and ready:

```bash
# Get the service IP
VLLM_IP=$(kubectl get svc vllm-service -n llm-workshop -o jsonpath='{.spec.clusterIP}')

# List available models
curl -s http://${VLLM_IP}:8000/v1/models | python3 -m json.tool || curl -s http://${VLLM_IP}:8000/v1/models
```{{exec}}

## Test the Model

Let's test our model with a simple prompt using the OpenAI-compatible API:

```bash
# Test 1: Basic question
curl -s http://${VLLM_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "What is Kubernetes?",
    "max_tokens": 100,
    "temperature": 0.7
  }' | python3 -m json.tool || curl -s http://${VLLM_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "What is Kubernetes?",
    "max_tokens": 100,
    "temperature": 0.7
  }'
```{{exec}}

## Run More Tests

Let's try a few more prompts to see how the model performs:

```bash
# Test 2: Technical question
curl -s http://${VLLM_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "Explain container orchestration in simple terms",
    "max_tokens": 100,
    "temperature": 0.7
  }' | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['text'])" 2>/dev/null || \
curl -s http://${VLLM_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "Explain container orchestration in simple terms",
    "max_tokens": 100,
    "temperature": 0.7
  }'
```{{exec}}

```bash
# Test 3: Creative task
curl -s http://${VLLM_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "Write a short haiku about cloud computing",
    "max_tokens": 50,
    "temperature": 0.8
  }' | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['text'])" 2>/dev/null || \
curl -s http://${VLLM_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "Write a short haiku about cloud computing",
    "max_tokens": 50,
    "temperature": 0.8
  }'
```{{exec}}

## Monitor Resource Usage

Let's check how our resources are being used:

```bash
# Check pod resource usage
kubectl top pod -l app=vllm-server -n llm-workshop 2>/dev/null || kubectl describe pod -l app=vllm-server -n llm-workshop | grep -A 10 "Limits\|Requests"

# Check pod status
kubectl get pods -n llm-workshop -o wide

# Check pod logs for any issues
kubectl logs -l app=vllm-server -n llm-workshop --tail=10
```{{exec}}

## Understanding Model Sizes

LLM models come in various sizes:

| Model Size | Parameters | Memory | Use Case |
|------------|-----------|--------|----------|
| Tiny (OPT-125M) | 125M | ~250MB | Learning, testing, simple tasks |
| Small | 1B-3B | 500MB-2GB | General purpose, good balance |
| Medium | 7B-13B | 4-8GB | Better quality, more capable |
| Large | 30B-70B+ | 16GB-40GB+ | Production, high quality |

For this workshop, **OPT-125M** is perfect because:
- Fits in our memory constraints
- Fast inference on CPU with vLLM
- Good enough for learning and demonstrations
- Quick to load and deploy
- Demonstrates CPU-based inference effectively

## Create a Test Script

Let's create a helper script for easier interaction:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/test-model.sh
#!/bin/bash

VLLM_IP=$(kubectl get svc vllm-service -n llm-workshop -o jsonpath='{.spec.clusterIP}')

echo "🤖 Testing vLLM with OPT-125M Model"
echo "===================================="
echo
echo "Service IP: ${VLLM_IP}"
echo
echo "Available models:"
curl -s http://${VLLM_IP}:8000/v1/models | python3 -m json.tool 2>/dev/null || curl -s http://${VLLM_IP}:8000/v1/models
echo
echo "Testing with question: What is Kubernetes?"
echo "-------------------------------------------"
curl -s http://${VLLM_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "What is Kubernetes?",
    "max_tokens": 100,
    "temperature": 0.7
  }' | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['text'])" 2>/dev/null || \
curl -s http://${VLLM_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "What is Kubernetes?",
    "max_tokens": 100,
    "temperature": 0.7
  }'
echo
EOF

chmod +x /root/workspace/llm-workshop/test-model.sh
```{{exec}}

## Run the Test Script

```bash
/root/workspace/llm-workshop/test-model.sh
```{{exec}}

## Model Deployment Summary

We've successfully:
- ✅ Verified OPT-125M model is loaded and ready
- ✅ Tested the model with various prompts using OpenAI-compatible API
- ✅ Monitored resource usage
- ✅ Created helper scripts for easier interaction
- ✅ Confirmed vLLM CPU mode is working correctly

## What's Next?

In the next step, we'll expose the vLLM service so we can interact with it from outside the cluster!

---

**Model working?** Let's expose it! 🚀
