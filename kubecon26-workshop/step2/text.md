# Step 2: Run Your First LLM and Understand Inference

You've deployed the inference server. Now let's load a model into it and have a conversation with an AI running inside your Kubernetes cluster.

## Understanding Model Selection

Choosing the right model is critical. Here's the landscape:

```
┌──────────────────────────────────────────────────────────────┐
│                    Model Size vs Capability                   │
├──────────┬────────────┬──────────┬───────────────────────────┤
│ Model    │ Parameters │ Memory   │ Best For                  │
├──────────┼────────────┼──────────┼───────────────────────────┤
│ TinyLlama│ 1.1B       │ ~637 MB  │ Learning, testing   <--   │
│ Phi-3    │ 3.8B       │ ~2.3 GB  │ Edge, mobile              │
│ Llama3   │ 8B         │ ~4.7 GB  │ General purpose           │
│ Mixtral  │ 47B (MoE)  │ ~26 GB   │ Complex reasoning         │
│ Llama3   │ 70B        │ ~40 GB   │ Production, high quality  │
│ Llama3   │ 405B       │ ~230 GB  │ Multi-GPU, frontier       │
└──────────┴────────────┴──────────┴───────────────────────────┘
```

We're using **TinyLlama (1.1B)** because it fits in our CPU environment. In production with GPUs, you'd typically use 8B-70B models.

## Pull the TinyLlama Model

This downloads the model weights into the Ollama pod. Think of it like pulling a container image, but for AI models:

```bash
kubectl exec -it deployment/ollama -n ai-workshop -- ollama pull tinyllama
```{{exec}}

> **What's downloading?** The model weights - 637MB of neural network parameters that encode the model's "knowledge". These are quantized (compressed) from the original 32-bit floats to 4-bit integers, reducing size by ~8x while keeping most quality.

## Verify Model is Loaded

```bash
kubectl exec deployment/ollama -n ai-workshop -- ollama list
```{{exec}}

## Chat with Your LLM

Let's ask it some questions! This is LLM inference running inside a Kubernetes pod:

```bash
echo "What is Kubernetes in 2 sentences?" | kubectl exec -i deployment/ollama -n ai-workshop -- ollama run tinyllama
```{{exec}}

## Understanding the Inference Process

What just happened when you asked that question? Let's trace the request:

```
┌──────────────────────────────────────────────────────────┐
│                    LLM Inference Flow                     │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  1. TOKENIZE: "What is Kubernetes" → [1724, 338, 29...]  │
│     Text converted to numbers the model understands       │
│                                                           │
│  2. PROCESS: Feed tokens through neural network layers    │
│     1.1 billion parameters process the input              │
│     This is where CPU/GPU matters most!                   │
│       - CPU: Sequential matrix operations (~5 tokens/s)   │
│       - GPU: Parallel matrix operations (~100 tokens/s)   │
│                                                           │
│  3. GENERATE: Predict next token, one at a time           │
│     "Kubernetes" → "is" → "an" → "open" → "source" →... │
│     Each token requires a full forward pass               │
│                                                           │
│  4. DECODE: Token IDs → text you can read                 │
│     [29...] → "Kubernetes is an open source..."           │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

## Try More Prompts

```bash
# Technical question
echo "Explain GPU sharing techniques: time-slicing, MPS, and MIG. Keep it short." | kubectl exec -i deployment/ollama -n ai-workshop -- ollama run tinyllama
```{{exec}}

```bash
# Creative task
echo "Write a haiku about running AI on Kubernetes" | kubectl exec -i deployment/ollama -n ai-workshop -- ollama run tinyllama
```{{exec}}

## Monitor Resources During Inference

Let's see how resources are consumed. Run this, then quickly run a prompt in the second command:

```bash
# Check resource usage
kubectl get pods -n ai-workshop -o wide
kubectl describe pod -l app=ollama -n ai-workshop | grep -A 3 "Limits\|Requests"

# Check Ollama logs for performance info
kubectl logs -l app=ollama -n ai-workshop --tail=5
```{{exec}}

## Use the Ollama API Directly

The Ollama REST API is how production applications connect. Let's use it through kubectl:

```bash
# Use the generate API endpoint
kubectl exec deployment/ollama -n ai-workshop -- curl -s http://localhost:11434/api/generate \
  -d '{"model": "tinyllama", "prompt": "What is a Kubernetes namespace?", "stream": false}' | python3 -m json.tool | head -20
```{{exec}}

> **Production Note**: In a real deployment, you'd expose this API via an Ingress or Gateway API with:
> - **Authentication** (OAuth2 proxy, API keys)
> - **Rate limiting** (to prevent GPU resource exhaustion)
> - **Load balancing** (across multiple model replicas)
> - **Observability** (request latency, tokens/second, queue depth)

## Speed Check: CPU vs GPU

On this CPU environment, you'll notice inference is slow (~3-8 tokens/second). Here's what GPU acceleration looks like in practice:

```
┌───────────────────────────────────────────────────────┐
│              Inference Speed Comparison                 │
├──────────────┬──────────────┬─────────────────────────┤
│ Hardware     │ Tokens/sec   │ Time for 100 tokens     │
├──────────────┼──────────────┼─────────────────────────┤
│ CPU (ours)   │ ~3-8 t/s     │ ~12-30 seconds          │
│ T4 GPU       │ ~30-50 t/s   │ ~2-3 seconds            │
│ A100 GPU     │ ~80-150 t/s  │ ~0.7-1.2 seconds        │
│ H100 GPU     │ ~150-300 t/s │ ~0.3-0.7 seconds        │
└──────────────┴──────────────┴─────────────────────────┘
```

This is exactly why GPUs matter for AI workloads, and why the GPU sharing techniques (MIG, MPS, time-slicing) we discussed in the slides are so important for maximizing utilization.

## Create a Quick-Query Script

Let's create a helper for the rest of the workshop:

```bash
cat <<'SCRIPT' > /root/workshop/ask.sh
#!/bin/bash
# Quick-query helper for the workshop
QUESTION="${*:-What is Kubernetes?}"
echo "Q: $QUESTION"
echo "---"
echo "$QUESTION" | kubectl exec -i deployment/ollama -n ai-workshop -- ollama run tinyllama
SCRIPT
chmod +x /root/workshop/ask.sh

# Test it
/root/workshop/ask.sh "What is a GPU and why is it used for AI?"
```{{exec}}

## Step Summary

You've successfully run an LLM on Kubernetes:

- Pulled TinyLlama model (1.1B parameters, 637MB)
- Interacted via both CLI and REST API
- Understood the inference pipeline (tokenize -> process -> generate -> decode)
- Saw why GPUs provide 10-100x speedup over CPU
- Created helper scripts for easy querying

**Next: But this LLM is making things up! Let's fix that with RAG.**
