# Introduction and Kubernetes Cluster Setup

Welcome to the **"LLM on Kubernetes Workshop"**! 

In this first step, we'll set up our Kubernetes environment and verify everything is ready for deploying LLM workloads.

## Check Kubernetes Cluster Status

First, let's verify our Kubernetes cluster is running:

```bash
kubectl get nodes
kubectl cluster-info
```{{exec}}

## Create Workshop Namespace

Let's create a dedicated namespace for our workshop. Namespaces help organize resources and provide isolation:

```bash
kubectl create namespace llm-workshop
kubectl config set-context --current --namespace=llm-workshop
```{{exec}}

## Verify Namespace

Let's confirm our namespace is created and we're using it:

```bash
kubectl get namespace llm-workshop
kubectl config view --minify | grep namespace
```{{exec}}

## Check Available Resources

Let's see what resources we have available in our cluster:

```bash
kubectl describe nodes
kubectl top nodes 2>/dev/null || echo "Metrics server not available (this is OK)"
```{{exec}}

## Create Workshop Directory

Let's create a workspace directory for our files:

```bash
mkdir -p /root/workspace/llm-workshop
cd /root/workspace/llm-workshop
pwd
```{{exec}}

## Understanding Namespaces

**Namespaces** in Kubernetes are like virtual clusters within a physical cluster. They provide:
- **Resource isolation** - Separate resources for different projects/teams
- **Access control** - Different permissions per namespace
- **Organization** - Group related resources together

We're using the `llm-workshop` namespace to keep all our workshop resources organized and separate from other workloads.

## Environment Summary

Our environment is now ready with:
- ✅ Kubernetes cluster running
- ✅ Workshop namespace created (`llm-workshop`)
- ✅ Context set to use the workshop namespace
- ✅ Workspace directory created

## What's Next?

In the next step, we'll deploy Ollama on Kubernetes and verify it runs on CPU!

---

**Environment ready?** Let's deploy Ollama! 🚀
