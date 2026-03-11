# Step 3: Build an Intelligent RAG Pipeline

Your LLM can chat, but it **hallucinates**. Ask it about specific topics and it'll confidently make things up. Let's fix that with **Retrieval-Augmented Generation (RAG)** - the #1 pattern for making LLMs useful in production.

## The Hallucination Problem

Let's prove the problem first. Ask about something specific:

```bash
echo "What is HPA in Kubernetes and what is the kubectl command to create one?" | kubectl exec -i deployment/ollama -n ai-workshop -- ollama run tinyllama
```{{exec}}

The answer might be partially correct, partially wrong. That's hallucination - the model generates plausible-sounding text without accurate knowledge.

## How RAG Fixes This

RAG has two phases:

```
INDEXING (one-time setup):
  Documents  -->  Chunking  -->  Embeddings  -->  Vector Store

QUERY (every question):
  Question  -->  Embed  -->  Search  -->  Add Context  -->  LLM  -->  Grounded Answer
```

The key insight: instead of asking the LLM to remember everything, we **retrieve** relevant documents and **augment** the prompt with real data. The LLM becomes a reasoning engine, not a knowledge base.

## Create a Knowledge Base

These documents represent your organization's private data - things the LLM doesn't know about:

```bash
cat <<'EOF' > /root/workshop/rag-app/documents/kubernetes-basics.txt
Kubernetes Basics

Kubernetes is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications. Originally designed by Google, now maintained by CNCF.

Key Concepts:
- Pods: Smallest deployable units containing one or more containers
- Services: Stable network endpoints for accessing pods (ClusterIP, NodePort, LoadBalancer)
- Deployments: Manage replica sets and rolling updates with zero downtime
- Namespaces: Virtual clusters for resource isolation between teams
- ConfigMaps: Store non-sensitive configuration as key-value pairs
- Secrets: Store sensitive data like passwords and API keys (base64 encoded)

Common Commands:
- kubectl get pods: List all pods
- kubectl describe pod <name>: Show pod details
- kubectl logs <pod>: View container logs
- kubectl apply -f <file>: Apply a manifest
EOF

cat <<'EOF' > /root/workshop/rag-app/documents/kubernetes-scaling.txt
Kubernetes Scaling and HPA

HPA - Horizontal Pod Autoscaler is the primary way to automatically scale applications in Kubernetes.

1. Horizontal Pod Autoscaler (HPA)
   - HPA automatically scales pod replicas based on CPU/memory utilization
   - HPA watches metrics-server data and adjusts replica count up or down
   - Create HPA: kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=50
   - View HPA: kubectl get hpa
   - HPA checks metrics every 15 seconds by default
   - Scaling decisions have a cooldown period to prevent flapping

2. Vertical Pod Autoscaler (VPA)
   - Adjusts resource requests/limits automatically based on actual usage
   - Right-sizes containers to avoid over/under-provisioning
   - Cannot be used simultaneously with HPA on the same metric

3. Cluster Autoscaler
   - Adds/removes nodes based on pending pods that cannot be scheduled
   - Works with cloud providers (AWS ASG, GCP MIG, Azure VMSS)
   - Scales down nodes that are underutilized for 10+ minutes

4. KEDA (Kubernetes Event-Driven Autoscaling)
   - Scales based on external events (queue depth, HTTP requests, cron)
   - Supports scaling to zero for cost savings
   - Perfect for batch processing and event-driven workloads
EOF

cat <<'EOF' > /root/workshop/rag-app/documents/kubernetes-security.txt
Kubernetes Security Best Practices

1. RBAC (Role-Based Access Control)
   - Define roles with minimum required permissions (principle of least privilege)
   - Use ServiceAccounts for pod identity, never use default SA in production
   - Regular access audits using kubectl auth can-i --list
   - Separate admin and developer roles

2. Network Policies
   - Control pod-to-pod traffic with ingress/egress rules
   - Default deny all, then explicitly allow required traffic
   - Namespace isolation prevents cross-team communication
   - Use Calico or Cilium for advanced policy features

3. Pod Security
   - Run containers as non-root user (runAsNonRoot: true)
   - Read-only root filesystem (readOnlyRootFilesystem: true)
   - Drop all capabilities, add only what's needed
   - Use securityContext at both pod and container level
   - Pod Security Standards: Restricted, Baseline, Privileged

4. Secrets Management
   - Never commit secrets to git repositories
   - Use external secret managers (HashiCorp Vault, AWS Secrets Manager)
   - Enable encryption at rest for etcd
   - Rotate secrets regularly with automated tools

5. Image Security
   - Scan images for CVEs using Trivy, Grype, or Snyk
   - Use signed images with cosign/Notary
   - Pin image digests, not just tags
   - Use minimal base images (distroless, Alpine)
EOF

cat <<'EOF' > /root/workshop/rag-app/documents/gpu-kubernetes.txt
Running GPU Workloads on Kubernetes

GPU Operator:
The NVIDIA GPU Operator automates the management of all NVIDIA software components needed to provision GPU workers. It deploys as a set of DaemonSets that install:
- NVIDIA driver
- NVIDIA Container Toolkit (nvidia-container-runtime)
- NVIDIA Device Plugin (registers nvidia.com/gpu resource)
- DCGM Exporter (GPU metrics for Prometheus)
- MIG Manager (for Multi-Instance GPU configuration)

GPU Sharing Techniques:
1. Time-Slicing: Pods take turns using the GPU. Simple but no isolation.
   - Configure via nvidia-device-plugin ConfigMap
   - Set replicas per GPU (e.g., 4 pods share 1 GPU)

2. MPS (Multi-Process Service): True concurrent execution on GPU.
   - Processes share GPU SMs simultaneously
   - Better throughput than time-slicing
   - Limited fault isolation

3. MIG (Multi-Instance GPU): Hardware-level partitioning (A100/H100 only).
   - GPU split into isolated instances with own memory and compute
   - Strongest isolation, guaranteed resources
   - Profiles: 1g.5gb, 2g.10gb, 3g.20gb, 4g.20gb, 7g.40gb (A100 80GB)

Requesting a GPU in Kubernetes:
  resources:
    limits:
      nvidia.com/gpu: 1

Requesting a MIG instance:
  resources:
    limits:
      nvidia.com/mig-3g.40gb: 1
EOF

echo "Created 4 knowledge base documents:"
ls -la /root/workshop/rag-app/documents/
```{{exec}}

## Build the Simple RAG Script

This is a keyword-based RAG to understand the concept before we upgrade to vectors:

```bash
cat <<'SCRIPT' > /root/workshop/rag-app/simple-rag.sh
#!/bin/bash
# Simple RAG - Keyword-based retrieval
# This demonstrates the RAG concept before we upgrade to vector search

DOCS_DIR="/root/workshop/rag-app/documents"

search_documents() {
    local query="$1"
    local best_doc="" best_score=0
    query_lower=$(echo "$query" | tr '[:upper:]' '[:lower:]')

    for doc in "$DOCS_DIR"/*.txt; do
        [ -f "$doc" ] || continue
        score=0
        for word in $query_lower; do
            [ ${#word} -gt 3 ] && score=$((score + $(grep -oi "$word" "$doc" 2>/dev/null | wc -l)))
        done
        [ $score -gt $best_score ] && { best_score=$score; best_doc="$doc"; }
    done
    [ $best_score -gt 0 ] && echo "$best_doc"
}

question="$1"
[ -z "$question" ] && { echo "Usage: $0 'your question'"; exit 1; }

echo "SIMPLE RAG (keyword matching)"
echo "=============================="
echo "Q: $question"
echo ""
echo "Searching documents..."
doc=$(search_documents "$question")

if [ -n "$doc" ]; then
    echo "Found: $(basename "$doc") (keyword match)"
    echo ""
    prompt="Based on the following documentation, answer this question concisely and accurately.

Documentation:
$(cat "$doc")

Question: $question

Answer:"
    echo "Generating answer with context..."
    echo "---"
    echo "$prompt" | kubectl exec -i deployment/ollama -n ai-workshop -- ollama run tinyllama
else
    echo "No matching document found, asking without context..."
    echo "---"
    echo "$question" | kubectl exec -i deployment/ollama -n ai-workshop -- ollama run tinyllama
fi
SCRIPT
chmod +x /root/workshop/rag-app/simple-rag.sh
echo "Simple RAG script created!"
```{{exec}}

## Test Simple RAG

Now let's see the difference RAG makes:

```bash
# Ask WITH RAG context - should give accurate HPA information
/root/workshop/rag-app/simple-rag.sh "What is HPA and how do I create one?"
```{{exec}}

```bash
# Ask about GPU topics - our new document helps!
/root/workshop/rag-app/simple-rag.sh "What GPU sharing techniques are available on Kubernetes?"
```{{exec}}

## See the Limitation of Keyword RAG

The keyword approach breaks when the query uses different words than the documents:

```bash
# This might NOT find the right document because the keywords don't match well
/root/workshop/rag-app/simple-rag.sh "How do I handle more traffic to my application?"
```{{exec}}

The user said "handle more traffic" but the document talks about "scaling" and "HPA". A human would understand these are the same concept, but keyword matching doesn't.

**This is exactly why we need vector/semantic search - which we'll build in the next step!**

## The RAG Pattern in Production

```
┌────────────────────────────────────────────────────────────────┐
│                Production RAG Architecture                      │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│  │ Ingress  │───>│ API GW   │───>│ RAG Svc  │───>│ LLM Svc  │ │
│  │ (NGINX)  │    │ (Auth,   │    │ (Search  │    │ (Ollama/  │ │
│  │          │    │  Rate    │    │  + Merge) │    │  vLLM)   │ │
│  └──────────┘    │  Limit)  │    └────┬─────┘    └──────────┘ │
│                  └──────────┘         │                        │
│                                  ┌────v─────┐                  │
│                                  │ Vector DB│                  │
│                                  │ (Qdrant/ │                  │
│                                  │ Pinecone)│                  │
│                                  └──────────┘                  │
│                                                                 │
│  Everything above runs as Kubernetes Deployments/Services      │
│  Each component can scale independently                        │
└────────────────────────────────────────────────────────────────┘
```

## Step Summary

- Created a 4-document knowledge base (K8s basics, scaling, security, GPU)
- Built a keyword-based RAG pipeline
- Proved that RAG eliminates hallucination by grounding answers in real data
- Identified the limitation: keyword search can't understand meaning/intent

**Next: We upgrade to vector-based semantic search that understands meaning!**
