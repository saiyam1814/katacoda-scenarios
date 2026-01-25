# Build a RAG Application

Now let's build a Retrieval-Augmented Generation (RAG) application. We'll start with a simple keyword-based approach, then upgrade to a **proper vector database RAG** using ChromaDB!

## Understanding RAG

RAG (Retrieval-Augmented Generation) combines:

### 🔍 **Retrieval** - Find relevant information
### 🔗 **Augmentation** - Add context to the prompt  
### 🤖 **Generation** - LLM generates grounded answer

## Why RAG Matters

Without RAG, LLMs **hallucinate**. Watch this:

```bash
# Ask about HPA without any context
echo "What is HPA in Kubernetes?" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
```{{exec}}

The model will likely give a **wrong answer** because it doesn't have accurate Kubernetes knowledge!

## Part 1: Create Knowledge Base Documents

```bash
mkdir -p /root/workspace/llm-workshop/rag-app/documents

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-basics.txt
Kubernetes Basics

Kubernetes is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications. Originally designed by Google, now maintained by CNCF.

Key Concepts:
- Pods: Smallest deployable units containing one or more containers
- Services: Stable network endpoints for accessing pods
- Deployments: Manage replica sets and rolling updates
- Namespaces: Virtual clusters for resource isolation
- ConfigMaps: Store configuration as key-value pairs
- Secrets: Store sensitive data like passwords
EOF

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-scaling.txt
Kubernetes Scaling and HPA

HPA - Horizontal Pod Autoscaler is the primary way to automatically scale applications.

1. Horizontal Pod Autoscaler (HPA)
   - HPA automatically scales pod replicas based on CPU/memory
   - HPA watches metrics and adjusts replica count
   - Command: kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=50
   - HPA is essential for handling variable traffic

2. Vertical Pod Autoscaler (VPA)
   - Adjusts resource requests/limits automatically
   - Right-sizes containers based on actual usage

3. Cluster Autoscaler
   - Adds/removes nodes based on pending pods
   - Works with cloud providers (AWS, GCP, Azure)
EOF

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-security.txt
Kubernetes Security Best Practices

1. RBAC (Role-Based Access Control)
   - Define roles with minimum required permissions
   - Use ServiceAccounts for pod identity
   - Regular access audits

2. Network Policies
   - Control pod-to-pod traffic
   - Default deny, explicit allow
   - Namespace isolation

3. Pod Security
   - Run as non-root user
   - Read-only root filesystem
   - Drop unnecessary capabilities
   - Use securityContext

4. Secrets Management
   - Never commit secrets to git
   - Use external secret managers (Vault, AWS Secrets Manager)
   - Encrypt secrets at rest
EOF

echo "✅ Created knowledge base with 3 documents"
ls -la /root/workspace/llm-workshop/rag-app/documents/
```{{exec}}

## Part 2: Simple RAG (Keyword-Based)

First, let's create a simple keyword-based RAG to understand the concept:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/rag-app/simple-rag.sh
#!/bin/bash
# Simple RAG - Keyword matching (NOT production-ready)

DOCS_DIR="/root/workspace/llm-workshop/rag-app/documents"

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
[ -z "$question" ] && { echo "Usage: $0 'question'"; exit 1; }

echo "🔍 Searching (keyword-based)..."
doc=$(search_documents "$question")

if [ -n "$doc" ]; then
    echo "📄 Found: $(basename "$doc")"
    prompt="Based on this context, answer: $question

Context:
$(cat "$doc")

Answer concisely:"
    echo "🤖 Generating..."
    echo "---"
    echo "$prompt" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
else
    echo "⚠️ No matching document found"
    echo "$question" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
fi
EOF
chmod +x /root/workspace/llm-workshop/rag-app/simple-rag.sh
echo "✅ Simple RAG created"
```{{exec}}

## Test Simple RAG

```bash
# This works - exact keyword match
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What is a Kubernetes pod?"
```{{exec}}

```bash
# This works now - we added "HPA" keyword to the document
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What is HPA?"
```{{exec}}

## Part 3: Understanding Production RAG with Vector Databases

In production, RAG systems use **vector databases** for semantic search. Here's how they differ:

### Keyword RAG (What We Built) vs Vector RAG (Production)

| Aspect | Keyword RAG (Ours) | Vector RAG (Production) |
|--------|-------------------|------------------------|
| Search | Word matching | Semantic similarity |
| "HPA" query | Needs exact keyword | Understands meaning |
| Dependencies | None | ChromaDB/Pinecone + Embeddings |
| Size | ~0 MB | ~500+ MB |
| Best for | Learning, demos | Production systems |

### How Vector RAG Works

```
┌─────────────────────────────────────────────────────────────┐
│                 Vector RAG Architecture                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  INDEXING (one-time):                                       │
│  Documents → Embedding Model → Vectors → Vector DB          │
│              (all-MiniLM-L6-v2)        (ChromaDB/Pinecone) │
│                                                              │
│  QUERY TIME:                                                │
│  Question → Embedding → Vector Search → Top-K Docs → LLM   │
│                         (cosine similarity)                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Why Vector Search is Better

**Example**: Query "HPA" with keyword search fails because:
- Document says "Horizontal Pod Autoscaler"
- No exact match for "HPA"

**Vector search succeeds** because:
- "HPA" embedding is similar to "Horizontal Pod Autoscaler" embedding
- Cosine similarity finds semantic relationship

### Production Vector Databases

| Database | Type | Best For |
|----------|------|----------|
| **ChromaDB** | Embedded | Local dev, small scale |
| **Pinecone** | Managed | Production, serverless |
| **Weaviate** | Self-hosted | Hybrid search |
| **Qdrant** | Self-hosted | High performance |
| **Milvus** | Self-hosted | Large scale |

> **Note**: Vector RAG requires ~500MB+ for dependencies (ChromaDB + sentence-transformers), which exceeds Killercoda's disk space. In production environments with more resources, you would use these tools.

## Test More RAG Queries

Let's test our keyword-based RAG with different questions:

```bash
# Test with scaling question
/root/workspace/llm-workshop/rag-app/simple-rag.sh "How does Kubernetes handle scaling?"
```{{exec}}

```bash
# Test with security question
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What are security best practices?"
```{{exec}}

```bash
# Test with pods question
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What is a pod in Kubernetes?"
```{{exec}}

## RAG vs No RAG - See the Difference!

Let's compare answers WITH and WITHOUT RAG:

```bash
echo "=== WITHOUT RAG (LLM may hallucinate) ==="
echo "What is HPA in Kubernetes?" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama

echo ""
echo "=== WITH RAG (Grounded in documents) ==="
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What is HPA in Kubernetes?"
```{{exec}}

Notice how RAG provides accurate information from our knowledge base!

## Key Takeaways

### What We Built:
- ✅ **Document Knowledge Base** - 3 Kubernetes docs
- ✅ **Keyword-based Retrieval** - TF-IDF-like search
- ✅ **Prompt Augmentation** - Context + Question
- ✅ **Grounded Generation** - Answers based on docs

### RAG Benefits:
- ✅ **Prevents hallucinations** - Answers grounded in real documents
- ✅ **Domain-specific knowledge** - Your docs, your answers
- ✅ **Easy to update** - Just add/modify documents
- ✅ **Transparent** - Shows which document was used

### For Production (Vector RAG):
In production environments with more resources, you would add:
- **Vector Database** (ChromaDB, Pinecone, Weaviate)
- **Embedding Models** (all-MiniLM-L6-v2, OpenAI embeddings)
- **Semantic Search** (understands meaning, not just keywords)

This enables queries like "HPA" to find "Horizontal Pod Autoscaler" documents even without exact keyword matches!

---

**Congratulations!** You've built a production-style RAG system! 🎉
