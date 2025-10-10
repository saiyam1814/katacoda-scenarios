# Setting up the Environment

Let's start by exploring our Kubernetes environment and preparing it for LLM workloads.

## Check Kubernetes Cluster Status

First, let's verify our Kubernetes cluster is running:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```{{exec}}

## Create Workshop Namespace

Let's create a dedicated namespace for our workshop:

```bash
kubectl create namespace llm-workshop
kubectl config set-context --current --namespace=llm-workshop
```{{exec}}

## Install Required Tools

We'll need some additional tools for our workshop. Let's install them:

```bash
# Install Helm (for package management)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install vcluster CLI (for multi-tenancy)
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && chmod +x vcluster && sudo mv vcluster /usr/local/bin

# Install jq for JSON processing
apt-get update && apt-get install -y jq
```

## Verify Installations

Let's check that everything is installed correctly:

```bash
# Check Helm version
helm version

# Check vcluster version
vcluster version

# Check jq version
jq --version
```

## Create Resource Quotas

Since we're working with limited resources, let's set up resource quotas:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: llm-workshop-quota
  namespace: llm-workshop
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
EOF
```

## Check Available Resources

Let's see what resources we have available:

```bash
kubectl describe nodes
kubectl top nodes
```

## Create Workshop Directory

Let's create a workspace directory for our files:

```bash
mkdir -p /root/workspace/llm-workshop
cd /root/workspace/llm-workshop
```

## Environment Summary

Our environment is now ready with:
- ✅ Kubernetes cluster running
- ✅ Workshop namespace created
- ✅ Helm installed for package management
- ✅ vcluster CLI for multi-tenancy
- ✅ jq for JSON processing
- ✅ Resource quotas configured

## What's Next?

In the next step, we'll deploy vLLM on Kubernetes and start running our first LLM model!

---

**Environment ready?** Let's deploy our first LLM! 🚀
