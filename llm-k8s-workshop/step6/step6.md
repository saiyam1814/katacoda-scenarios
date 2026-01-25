# Build a RAG Application

Now let's build a Retrieval-Augmented Generation (RAG) application. We'll start with a simple keyword-based approach, then upgrade to a **proper vector database RAG** using Ollama's embedding API!

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

## Part 3: Vector RAG with Ollama Embeddings! 🚀

Now let's build a **proper vector database RAG** using:
- **Ollama's Embedding API** - Built-in, no extra packages!
- **all-minilm** - Smallest embedding model (23M params, ~45MB)
- **NumPy** - For cosine similarity (~30MB)

**Total: ~75MB** (vs ~500MB for ChromaDB + sentence-transformers)

### Pull the Embedding Model

```bash
# Pull the smallest embedding model (all-minilm - only 45MB!)
kubectl exec -it deployment/ollama-server -n llm-workshop -- ollama pull all-minilm
```{{exec}}

### Install NumPy for Vector Math

```bash
# Install numpy (only ~30MB - lightweight!)
pip3 install numpy --quiet --break-system-packages
echo "✅ NumPy installed for vector operations"
```{{exec}}

### How Vector RAG Works

```
┌─────────────────────────────────────────────────────────────┐
│                 Vector RAG Architecture                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  INDEXING (one-time):                                       │
│  Documents → Ollama Embeddings → Vectors → JSON Store       │
│              (all-minilm)                                    │
│                                                              │
│  QUERY TIME:                                                │
│  Question → Embedding → Cosine Similarity → Top Doc → LLM  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Create Vector RAG Application

```bash
cat <<'EOF' > /root/workspace/llm-workshop/rag-app/vector-rag.py
#!/usr/bin/env python3
"""
Vector RAG using Ollama Embeddings API
No heavy dependencies - just numpy!
"""

import json
import os
import subprocess
import numpy as np

DOCS_DIR = "/root/workspace/llm-workshop/rag-app/documents"
EMBEDDINGS_FILE = "/root/workspace/llm-workshop/rag-app/embeddings.json"
OLLAMA_SERVICE = "ollama-service.llm-workshop.svc.cluster.local:11434"

def get_embedding(text):
    """Get embedding from Ollama API via kubectl"""
    # Use kubectl to call Ollama's embedding API
    payload = json.dumps({"model": "all-minilm", "input": text})
    cmd = f'''kubectl exec -i deployment/ollama-server -n llm-workshop -- \
        curl -s http://localhost:11434/api/embed -d '{payload}' '''
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    try:
        response = json.loads(result.stdout)
        return response.get("embeddings", [[]])[0]
    except:
        return []

def cosine_similarity(a, b):
    """Calculate cosine similarity between two vectors"""
    a, b = np.array(a), np.array(b)
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

def index_documents():
    """Index all documents with embeddings"""
    print("📚 Indexing documents with Ollama embeddings...")
    embeddings = {}
    
    for filename in os.listdir(DOCS_DIR):
        if filename.endswith('.txt'):
            filepath = os.path.join(DOCS_DIR, filename)
            with open(filepath, 'r') as f:
                content = f.read()
            
            print(f"  🔄 Embedding: {filename}")
            embedding = get_embedding(content[:500])  # First 500 chars
            
            if embedding:
                embeddings[filename] = {
                    "content": content,
                    "embedding": embedding
                }
                print(f"  ✅ {filename} ({len(embedding)} dimensions)")
    
    with open(EMBEDDINGS_FILE, 'w') as f:
        json.dump(embeddings, f)
    
    print(f"\n✅ Indexed {len(embeddings)} documents!")
    return embeddings

def load_embeddings():
    """Load pre-computed embeddings"""
    if os.path.exists(EMBEDDINGS_FILE):
        with open(EMBEDDINGS_FILE, 'r') as f:
            return json.load(f)
    return index_documents()

def semantic_search(query, embeddings):
    """Find most similar document using cosine similarity"""
    print(f"🔍 Semantic search: '{query}'")
    
    query_embedding = get_embedding(query)
    if not query_embedding:
        return None, None
    
    best_doc = None
    best_score = -1
    
    for filename, data in embeddings.items():
        score = cosine_similarity(query_embedding, data["embedding"])
        print(f"  📄 {filename}: {score:.4f}")
        if score > best_score:
            best_score = score
            best_doc = filename
    
    return best_doc, best_score

def ask_ollama(prompt):
    """Send prompt to Ollama"""
    result = subprocess.run(
        ["kubectl", "exec", "-i", "deployment/ollama-server", 
         "-n", "llm-workshop", "--", "ollama", "run", "tinyllama"],
        input=prompt, text=True, capture_output=True, timeout=120
    )
    return result.stdout.strip()

def rag_query(question):
    """Full RAG pipeline with vector search"""
    embeddings = load_embeddings()
    
    best_doc, score = semantic_search(question, embeddings)
    
    if best_doc and score > 0.3:
        print(f"\n📄 Best match: {best_doc} (similarity: {score:.4f})")
        context = embeddings[best_doc]["content"]
        
        prompt = f"""Based on this context, answer the question concisely.

Context:
{context}

Question: {question}

Answer:"""
        
        print("🤖 Generating answer with context...")
        print("---")
        answer = ask_ollama(prompt)
        print(answer)
    else:
        print("⚠️ No relevant documents found, asking without context...")
        print(ask_ollama(question))

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 vector-rag.py 'your question'")
        print("\nOr use 'index' to re-index documents:")
        print("  python3 vector-rag.py index")
        sys.exit(0)
    
    if sys.argv[1] == "index":
        index_documents()
    else:
        question = " ".join(sys.argv[1:])
        rag_query(question)
EOF

chmod +x /root/workspace/llm-workshop/rag-app/vector-rag.py
echo "✅ Vector RAG application created"
```{{exec}}

### Index Documents (One-Time)

```bash
# Create embeddings for all documents
python3 /root/workspace/llm-workshop/rag-app/vector-rag.py index
```{{exec}}

## Test Vector RAG - See the Magic! ✨

Now test with semantic understanding:

```bash
# Test 1: "HPA" finds "Horizontal Pod Autoscaler" semantically!
python3 /root/workspace/llm-workshop/rag-app/vector-rag.py "What is HPA?"
```{{exec}}

```bash
# Test 2: Semantic search finds related concepts
python3 /root/workspace/llm-workshop/rag-app/vector-rag.py "How do I scale my application automatically?"
```{{exec}}

```bash
# Test 3: Security question
python3 /root/workspace/llm-workshop/rag-app/vector-rag.py "How to secure my cluster?"
```{{exec}}

## Compare: Simple RAG vs Vector RAG

```bash
echo "=== SIMPLE RAG (Keyword matching) ==="
/root/workspace/llm-workshop/rag-app/simple-rag.sh "auto scaling apps"

echo ""
echo "=== VECTOR RAG (Semantic similarity) ==="
python3 /root/workspace/llm-workshop/rag-app/vector-rag.py "auto scaling apps"
```{{exec}}

## Why Vector Search is Better

| Query | Keyword RAG | Vector RAG |
|-------|-------------|------------|
| "HPA" | ❌ May miss | ✅ Finds scaling docs |
| "auto scaling" | ❌ Partial | ✅ Semantic match |
| "secure pods" | ❌ May miss | ✅ Finds security docs |
| "container orchestration" | ❌ No match | ✅ Finds basics |

## Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                What We Built Today                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📄 Knowledge Base (3 Kubernetes documents)                 │
│         ↓                                                    │
│  🔢 Ollama Embeddings (all-minilm model)                   │
│         ↓                                                    │
│  💾 Vector Store (JSON file with embeddings)               │
│         ↓                                                    │
│  🔍 Cosine Similarity Search (NumPy)                       │
│         ↓                                                    │
│  🤖 LLM Generation (tinyllama with context)                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Key Takeaways

### What We Built:
- ✅ **Keyword RAG** - Simple word matching approach
- ✅ **Vector RAG** - Real semantic search with embeddings!
- ✅ **Ollama Embeddings** - No external API needed
- ✅ **Minimal Dependencies** - Just NumPy (~30MB)

### Production Enhancements:
For production, scale up with:
- **ChromaDB/Pinecone/Qdrant** - Managed vector databases
- **Larger embedding models** - Better accuracy
- **Chunking** - Split large documents
- **Hybrid search** - Combine keyword + vector

---

**Congratulations!** You've built a real vector database RAG system! 🎉
