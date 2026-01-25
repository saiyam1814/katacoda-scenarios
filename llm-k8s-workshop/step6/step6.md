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

## Part 3: Production RAG with Vector Database! 🚀

Now let's build a **proper RAG** using:
- **ChromaDB** - Lightweight vector database
- **Sentence Transformers** - For text embeddings
- **Semantic Search** - Finds related concepts, not just keywords!

### Install Dependencies

```bash
# Create a virtual environment for Python packages
python3 -m venv /root/workspace/llm-workshop/rag-venv

# Install dependencies using the venv pip directly (avoids PEP 668 issues)
/root/workspace/llm-workshop/rag-venv/bin/pip install --upgrade pip --quiet
/root/workspace/llm-workshop/rag-venv/bin/pip install chromadb sentence-transformers --quiet

echo "✅ Vector database dependencies installed"
echo "📍 Virtual environment: /root/workspace/llm-workshop/rag-venv"
echo "📍 Use: /root/workspace/llm-workshop/rag-venv/bin/python to run scripts"
```{{exec}}

### Create Vector RAG Application

```bash
cat <<'EOF' > /root/workspace/llm-workshop/rag-app/vector-rag.py
#!/usr/bin/env python3
"""
Production-style RAG with Vector Database
Uses ChromaDB for semantic search
"""

import chromadb
from sentence_transformers import SentenceTransformer
import subprocess
import os
import sys

# Initialize embedding model (small and fast)
print("🔄 Loading embedding model...")
embedder = SentenceTransformer('all-MiniLM-L6-v2')

# Initialize ChromaDB (in-memory for simplicity)
client = chromadb.Client()

# Create or get collection
try:
    collection = client.get_collection("kubernetes_docs")
    print("📚 Using existing vector collection")
except:
    collection = client.create_collection(
        name="kubernetes_docs",
        metadata={"description": "Kubernetes knowledge base"}
    )
    print("📚 Created new vector collection")
    
    # Load and index documents
    docs_dir = "/root/workspace/llm-workshop/rag-app/documents"
    documents = []
    metadatas = []
    ids = []
    
    for filename in os.listdir(docs_dir):
        if filename.endswith('.txt'):
            filepath = os.path.join(docs_dir, filename)
            with open(filepath, 'r') as f:
                content = f.read()
                documents.append(content)
                metadatas.append({"source": filename})
                ids.append(filename)
                print(f"  📄 Indexed: {filename}")
    
    # Add documents to collection (ChromaDB auto-embeds with default)
    collection.add(
        documents=documents,
        metadatas=metadatas,
        ids=ids
    )
    print(f"✅ Indexed {len(documents)} documents")

def semantic_search(query, n_results=2):
    """Search using vector similarity"""
    results = collection.query(
        query_texts=[query],
        n_results=n_results
    )
    return results

def ask_ollama(prompt):
    """Send prompt to Ollama"""
    try:
        result = subprocess.run(
            ["kubectl", "exec", "-i", "deployment/ollama-server", 
             "-n", "llm-workshop", "--", "ollama", "run", "tinyllama"],
            input=prompt,
            text=True,
            capture_output=True,
            timeout=60
        )
        return result.stdout.strip()
    except Exception as e:
        return f"Error: {e}"

def rag_query(question):
    """Full RAG pipeline"""
    print(f"\n🔍 Semantic search for: '{question}'")
    
    # Semantic search
    results = semantic_search(question)
    
    if results['documents'][0]:
        # Get top result
        top_doc = results['documents'][0][0]
        source = results['metadatas'][0][0]['source']
        
        print(f"📄 Found relevant document: {source}")
        print(f"   (Using vector similarity - understands meaning!)")
        
        # Create augmented prompt
        prompt = f"""Based on this context about Kubernetes, answer the question.

Context:
{top_doc}

Question: {question}

Answer concisely based on the context:"""
        
        print("🤖 Generating answer...")
        print("---")
        answer = ask_ollama(prompt)
        print(answer)
    else:
        print("⚠️ No relevant documents found")
        answer = ask_ollama(question)
        print(answer)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("🤖 Vector RAG - Semantic Search")
        print("Usage: python3 vector-rag.py 'your question'")
        print("\nThis uses VECTOR SIMILARITY to find related documents,")
        print("not just keyword matching!")
        sys.exit(0)
    
    question = " ".join(sys.argv[1:])
    rag_query(question)
EOF

chmod +x /root/workspace/llm-workshop/rag-app/vector-rag.py
echo "✅ Vector RAG application created"
```{{exec}}

## Test Vector RAG - See the Magic! ✨

```bash
# Test 1: This works with SEMANTIC understanding
/root/workspace/llm-workshop/rag-venv/bin/python /root/workspace/llm-workshop/rag-app/vector-rag.py "What is HPA?"
```{{exec}}

```bash
# Test 2: Semantic search finds related concepts!
/root/workspace/llm-workshop/rag-venv/bin/python /root/workspace/llm-workshop/rag-app/vector-rag.py "How do I automatically scale my application?"
```{{exec}}

```bash
# Test 3: Even vague questions work!
/root/workspace/llm-workshop/rag-venv/bin/python /root/workspace/llm-workshop/rag-app/vector-rag.py "How to secure my cluster?"
```{{exec}}

## Compare: Simple RAG vs Vector RAG

```bash
echo "=== SIMPLE RAG (Keyword) ==="
/root/workspace/llm-workshop/rag-app/simple-rag.sh "auto scaling apps"

echo ""
echo "=== VECTOR RAG (Semantic) ==="
/root/workspace/llm-workshop/rag-venv/bin/python /root/workspace/llm-workshop/rag-app/vector-rag.py "auto scaling apps"
```{{exec}}

## How Vector RAG Works

```
┌─────────────────────────────────────────────────────────────┐
│                    Vector RAG Pipeline                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Document Indexing (one-time):                           │
│     Documents → Embedding Model → Vectors → ChromaDB        │
│                                                              │
│  2. Query Time:                                             │
│     Question → Embedding Model → Query Vector               │
│         ↓                                                    │
│     ChromaDB → Cosine Similarity → Top-K Documents          │
│         ↓                                                    │
│     Context + Question → Ollama → Answer                    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Why Vector Search is Better

| Query | Keyword RAG | Vector RAG |
|-------|-------------|------------|
| "HPA" | ❌ Needs exact match | ✅ Understands it's about scaling |
| "auto scaling" | ❌ Partial match | ✅ Finds scaling docs |
| "secure my pods" | ❌ May miss | ✅ Finds security docs |
| "container orchestration" | ❌ May miss | ✅ Finds Kubernetes basics |

## Key Components

### 1. **Embedding Model** (all-MiniLM-L6-v2)
- Converts text to 384-dimensional vectors
- Small (80MB) and fast
- Captures semantic meaning

### 2. **Vector Database** (ChromaDB)
- Stores document embeddings
- Fast similarity search
- Lightweight, runs in-memory

### 3. **Similarity Search**
- Cosine similarity between query and documents
- Finds semantically related content
- No exact keyword match needed!

## Production Enhancements

For real production RAG, add:

```
┌─────────────────────────────────────────────────────────┐
│  Production RAG Architecture                             │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  📄 Document Processing                                  │
│     • Chunking (split long docs)                        │
│     • Metadata extraction                               │
│     • Deduplication                                     │
│                                                          │
│  🗄️ Vector Database (choose one)                        │
│     • Pinecone (managed, scalable)                      │
│     • Weaviate (open source, hybrid search)            │
│     • Qdrant (fast, filtering)                         │
│     • Milvus (large scale)                             │
│                                                          │
│  🔍 Retrieval Enhancements                              │
│     • Hybrid search (vector + keyword)                  │
│     • Reranking (cross-encoder)                        │
│     • Query expansion                                   │
│                                                          │
│  🤖 Generation                                          │
│     • Larger models (Llama-7B, Mistral)               │
│     • Streaming responses                               │
│     • Citation/source tracking                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Summary

We built TWO types of RAG:

| Feature | Simple RAG | Vector RAG |
|---------|------------|------------|
| Search Method | Keyword matching | Semantic vectors |
| Database | File system | ChromaDB |
| Embeddings | None | all-MiniLM-L6-v2 |
| Accuracy | Limited | Production-quality |
| "HPA" query | Needs keyword | Understands meaning |

### Key Takeaways:
- ✅ RAG prevents hallucinations by grounding answers in documents
- ✅ Vector search understands **meaning**, not just keywords
- ✅ ChromaDB is lightweight and perfect for learning
- ✅ Same pattern scales to production with Pinecone/Weaviate

---

**Congratulations!** You've built a production-style RAG system! 🎉
