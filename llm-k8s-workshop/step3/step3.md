# Run the Smallest LLM Model

Now let's pull and run the smallest LLM model - TinyLlama. This model is perfect for our CPU-based environment as it's lightweight and fast.

## Understanding TinyLlama

**TinyLlama** is:
- **Ultra Lightweight**: Only 1.1B parameters (~637MB)
- **Fast**: Quick inference times even on CPU
- **Capable**: Good performance for many tasks despite small size
- **Open Source**: Free to use and modify
- **Memory Efficient**: Designed to work in low-memory environments

## Pull TinyLlama Model

Let's pull the TinyLlama model into our Ollama deployment:

```bash
# Pull TinyLlama model (this may take a few minutes)
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama pull tinyllama
```{{exec}}

## Verify Model Installation

Let's check that the model is installed:

```bash
# List installed models
kubectl exec deployment/ollama-server -n llm-workshop -- ollama list
```{{exec}}

## Test the Model

Let's test our model with a simple prompt:

```bash
# Test with a basic question
echo "What is Kubernetes?" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
```{{exec}}

## Run More Tests

Let's try a few more prompts to see how the model performs:

```bash
# Test 2: Technical question
echo "Explain container orchestration in simple terms" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
```{{exec}}

```bash
# Test 3: Creative task
echo "Write a short haiku about cloud computing" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
```{{exec}}

## Monitor Resource Usage

Let's check how our resources are being used:

```bash
# Check pod status
kubectl get pods -n llm-workshop -o wide

# Check pod logs
kubectl logs -l app=ollama-server -n llm-workshop --tail=10
```{{exec}}

## Understanding Model Sizes

LLM models come in various sizes:

| Model Size | Parameters | Memory | Use Case |
|------------|-----------|--------|----------|
| Tiny (TinyLlama) | 1.1B | ~637MB | Learning, testing, simple tasks |
| Small (Phi-2) | 2.7B | ~1.5GB | General purpose, good balance |
| Medium (Llama 7B) | 7B | ~4GB | Better quality, more capable |
| Large (Llama 70B) | 70B | ~40GB | Production, high quality |

For this workshop, **TinyLlama (1.1B)** is perfect because:
- Fits in our memory constraints
- Fast inference on CPU
- Good enough for learning and demonstrations
- Quick to download and deploy

## Create a Test Script

Let's create a helper script for easier interaction:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/test-model.sh
#!/bin/bash

echo "🤖 Testing TinyLlama Model"
echo "=========================="
echo
echo "Available models:"
kubectl exec deployment/ollama-server -n llm-workshop -- ollama list
echo
echo "Testing with question: What is Kubernetes?"
echo "-------------------------------------------"
echo "What is Kubernetes?" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
EOF

chmod +x /root/workspace/llm-workshop/test-model.sh
```{{exec}}

## Run the Test Script

```bash
/root/workspace/llm-workshop/test-model.sh
```{{exec}}

## Model Deployment Summary

We've successfully:
- ✅ Pulled TinyLlama model (1.1B parameters)
- ✅ Verified the model is available
- ✅ Tested the model with various prompts
- ✅ Created helper scripts for easier interaction

## What's Next?

In the next step, we'll expose the Ollama service so we can interact with it more easily!

---

**Model working?** Let's expose it! 🚀
