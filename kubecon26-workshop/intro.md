# GPU, AI & Multi-Tenancy on Kubernetes

## KubeCon EU 2026 - Pre-Conference Workshop

Welcome to this hands-on workshop! You just saw Artem demonstrate the **vCluster Platform Blueprint** - from vind to Kubera to vCluster connecting to GPU infrastructure with Auto Nodes. Now it's time to understand **what runs on that platform** and build it yourself.

## What You'll Build in 30 Minutes

In this workshop, you'll go from zero to a working **multi-tenant AI platform** on Kubernetes:

```
Step 1: Deploy Ollama (LLM inference server) on Kubernetes
Step 2: Pull a model, chat with it, monitor the inference
Step 3: Build a RAG pipeline with document knowledge
Step 4: Upgrade to vector-based semantic search (real embeddings!)
Step 5: Create isolated AI environments using vCluster
```

## The Big Picture

Every step you do here on CPU maps directly to production with GPUs:

| Workshop (CPU)           | Production (GPU)                     |
|--------------------------|--------------------------------------|
| Ollama on CPU            | Ollama/vLLM on NVIDIA A100/H100     |
| TinyLlama (1.1B params)  | Llama 3 70B / Mixtral               |
| JSON vector store        | Qdrant / Pinecone / ChromaDB         |
| vCluster (single node)   | vCluster + Auto Nodes + MIG          |

## Prerequisites

- Basic familiarity with `kubectl` commands
- No GPU required - we're using CPU-optimized models!
- Everything runs in this browser environment

## Architecture Overview

```
                    +-------------------+
                    | Your Questions    |
                    +--------+----------+
                             |
                    +--------v----------+
                    | RAG Pipeline      |
                    | (Vector Search)   |
                    +--------+----------+
                             |
                    +--------v----------+
                    | Ollama Server     |
                    | (TinyLlama 1.1B)  |
                    +--------+----------+
                             |
                    +--------v----------+
                    | Kubernetes Pod    |
                    | (Resource Managed)|
                    +--------+----------+
                             |
                    +--------v----------+
                    | vCluster          |
                    | (Team Isolation)  |
                    +-------------------+
```

**Let's get started!**
