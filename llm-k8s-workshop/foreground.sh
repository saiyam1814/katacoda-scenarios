#!/bin/bash

# Foreground script for LLM on Kubernetes workshop
# This script runs in the foreground during the workshop

echo "🎯 LLM on Kubernetes Workshop"
echo "=============================="
echo
echo "Welcome to the workshop! Let's get started with deploying LLMs on Kubernetes."
echo
echo "📋 Workshop Overview:"
echo "  • Deploy vLLM with CPU mode for high-performance LLM inference"
echo "  • Run lightweight models on Kubernetes"
echo "  • Build a RAG application with document knowledge"
echo "  • Understand cloud-native AI workloads"
echo
echo "🛠️  Environment Status:"
echo "  • Kubernetes cluster: $(kubectl get nodes --no-headers 2>/dev/null | wc -l) nodes"
echo "  • Namespace: llm-workshop"
echo "  • Runtime: vLLM CPU mode (used by llm-d)"
echo
echo "🚀 Ready to start! Follow the steps in the workshop."
echo
