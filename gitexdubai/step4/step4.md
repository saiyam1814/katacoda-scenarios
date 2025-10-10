# Running a Lightweight LLM Model

Now let's explore our Ollama deployment and create a simple web interface for easier interaction.

## Understanding Our Model

We're using **TinyLlama**, which is:
- **Ultra Lightweight**: Perfect for memory-constrained environments (1.1B parameters, ~637MB)
- **Fast**: Quick inference times with Ollama optimization
- **Capable**: Good performance for many tasks despite small size
- **Open Source**: Free to use and modify
- **Memory Efficient**: Designed to work in low-memory environments

## Test the Model

Let's test our model with various prompts:

```bash
# Test 1: Basic question
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama run tinyllama "What is Kubernetes?"

# Test 2: Technical question
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama run tinyllama "Explain container orchestration in simple terms"

# Test 3: Creative task
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama run tinyllama "Write a short poem about cloud computing"
```{{exec}}

## Create a Simple Test Script

Let's create a simple test script for easier interaction:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/test-ollama.sh
#!/bin/bash

echo "Testing Ollama..."
echo "Available models:"
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama list

echo -e "\nTesting model inference:"
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama run tinyllama "What is Kubernetes?"
EOF

chmod +x /root/workspace/llm-workshop/test-ollama.sh
```

## Run the Test Script

```bash
/root/workspace/llm-workshop/test-ollama.sh
```{{exec}}

## Monitor Resource Usage

Let's check how our resources are being used:

```bash
kubectl top pods -n llm-workshop
kubectl describe pods -n llm-workshop
```

## LLM Deployment Summary

We've successfully:
- ✅ Deployed Ollama with TinyLlama model
- ✅ Tested various types of prompts
- ✅ Created helper scripts for easier interaction
- ✅ Monitored resource usage
- ✅ Verified Ollama functionality

## What's Next?

In the next step, we'll build a Retrieval-Augmented Generation (RAG) application that can answer questions based on specific documents!

---

**Model working?** Let's build something even more powerful! 🚀
