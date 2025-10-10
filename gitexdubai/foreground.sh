#!/bin/bash

# Foreground script for LLM on Kubernetes workshop
# This script runs in the foreground during the workshop

echo "🎯 LLM on Kubernetes Workshop - GITEX Dubai 2025"
echo "================================================"
echo
echo "Welcome to the workshop! Let's get started with deploying LLMs on Kubernetes."
echo
echo "📋 Workshop Overview:"
echo "  • Deploy vLLM for high-performance CPU inference"
echo "  • Build a RAG application with document knowledge"
echo "  • Implement multi-tenancy with vcluster"
echo "  • Scale and optimize LLM workloads"
echo
echo "🛠️  Environment Status:"
echo "  • Kubernetes cluster: $(kubectl get nodes --no-headers | wc -l) nodes"
echo "  • Namespace: llm-workshop"
echo "  • Tools installed: Helm, vcluster, jq"
echo
echo "🚀 Ready to start! Follow the steps in the workshop."
echo
