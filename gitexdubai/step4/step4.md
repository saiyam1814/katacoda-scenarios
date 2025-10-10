# Running a Lightweight LLM Model

Now let's explore advanced features of our LLM deployment and create a simple web interface for easier interaction.

## Understanding Our Model

We're using **Facebook OPT-125M**, which is:
- **Lightweight**: Perfect for CPU-based environments (125M parameters)
- **Fast**: Quick inference times with vLLM optimization
- **Capable**: Good performance for many tasks
- **Open Source**: Free to use and modify
- **vLLM Optimized**: Takes full advantage of vLLM's CPU optimizations

## Test the Model

Let's test our model with various prompts:

```bash
# Test 1: Basic question
curl -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "What is Kubernetes?",
    "max_tokens": 50
  }'

# Test 2: Technical question
curl -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "Explain container orchestration in simple terms",
    "max_tokens": 50
  }'

# Test 3: Creative task
curl -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "Write a short poem about cloud computing",
    "max_tokens": 50
  }'
```

## Create a Simple Test Script

Let's create a simple test script for easier interaction:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/test-vllm.sh
#!/bin/bash

echo "Testing vLLM API..."
echo "Health check:"
curl -s http://localhost:8000/health | jq .

echo -e "\nAvailable models:"
curl -s http://localhost:8000/v1/models | jq '.data[].id'

echo -e "\nTesting model inference:"
curl -s -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "What is Kubernetes?",
    "max_tokens": 50
  }' | jq '.choices[0].text'
EOF

chmod +x /root/workspace/llm-workshop/test-vllm.sh
```

## Run the Test Script

```bash
/root/workspace/llm-workshop/test-vllm.sh
```

## Monitor Resource Usage

Let's check how our resources are being used:

```bash
kubectl top pods -n llm-workshop
kubectl describe pods -n llm-workshop
```

## LLM Deployment Summary

We've successfully:
- ✅ Deployed vLLM with Facebook OPT-125M model
- ✅ Tested various types of prompts
- ✅ Created helper scripts for easier interaction
- ✅ Monitored resource usage
- ✅ Verified API functionality

## What's Next?

In the next step, we'll build a Retrieval-Augmented Generation (RAG) application that can answer questions based on specific documents!

---

**Model working?** Let's build something even more powerful! 🚀
