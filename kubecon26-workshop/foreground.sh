#!/bin/bash

clear
echo "============================================================"
echo "  GPU, AI & Multi-Tenancy on Kubernetes"
echo "  KubeCon EU 2026 - Amsterdam"
echo "============================================================"
echo ""
echo "  Workshop by Saiyam Pathak"
echo ""
echo "  What you'll build:"
echo "    1. Deploy an LLM inference server on Kubernetes"
echo "    2. Chat with an AI model running in your cluster"
echo "    3. Build a RAG pipeline with semantic vector search"
echo "    4. Create isolated multi-tenant AI environments"
echo ""
echo "  Environment:"
echo "    Kubernetes cluster: $(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ') nodes"
echo "    Runtime: Ollama (CPU-compatible)"
echo "    Models: TinyLlama (1.1B) + all-minilm (embeddings)"
echo ""
echo "  Waiting for background setup to complete..."
echo ""

# Wait for namespace to be ready
until kubectl get namespace ai-workshop &>/dev/null; do sleep 1; done

echo "  Setup complete! Follow the steps to begin."
echo "============================================================"
