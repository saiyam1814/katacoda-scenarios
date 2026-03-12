# Step 4: Vector RAG with Semantic Search

Time to upgrade from keyword matching to **real semantic search** using vector embeddings. This is how production RAG systems work - and we'll do it with zero external APIs, right inside our Kubernetes cluster.

## What Are Vector Embeddings?

Remember how the LLM works by predicting the next token? Embedding models do something different - they read the **entire text** and compress its meaning into a list of numbers called a **vector**.

```
"How do I handle more traffic?"  →  [0.12, -0.34, 0.56, 0.23, ...]  (384 numbers)
"Kubernetes scaling with HPA"    →  [0.11, -0.31, 0.53, 0.25, ...]  (384 numbers)
"Pod security best practices"   →  [0.78, 0.12, -0.45, 0.02, ...]  (384 numbers)
                                          ↑ First two are CLOSE!
```

**What do the 384 dimensions mean?** Think of it like coordinates. In 2D, a point has (x, y). In 384D, each number captures a different aspect of meaning - topics, sentiment, technical level, domain, etc. The model learns WHAT each dimension represents during training. We don't manually define them.

**Cosine similarity** measures the angle between two vectors (1.0 = identical meaning, 0.0 = completely unrelated). Two texts about "scaling applications" will have vectors pointing in a similar direction, even if they use completely different words.

## Pull the Embedding Model

We'll use **all-minilm** - a tiny (23M params, ~45MB) but effective embedding model:

```bash
kubectl exec -it deployment/ollama -n ai-workshop -- ollama pull all-minilm
```{{exec}}

```bash
# Verify both models are available
kubectl exec deployment/ollama -n ai-workshop -- ollama list
```{{exec}}

## Start Port-Forward for the Embedding API

We need to access Ollama's REST API from the host to use the embedding endpoint:

```bash
# Start port-forward in background
kubectl port-forward svc/ollama -n ai-workshop 11434:11434 &
sleep 3

# Test the embedding API
echo "Testing embedding API..."
curl -s http://localhost:11434/api/embed \
  -d '{"model": "all-minilm", "input": "Hello Kubernetes"}' | python3 -c "
import sys, json
data = json.load(sys.stdin)
emb = data.get('embeddings', [[]])[0]
print(f'Embedding dimensions: {len(emb)}')
print(f'First 5 values: {emb[:5]}')
print(f'Vector type: float32')
"
```{{exec}}

> **384 numbers per text!** Each piece of text becomes a point in 384-dimensional space. The embedding model learned (during its training on millions of text pairs) to place similar-meaning texts CLOSE together in this space. "scaling applications" and "handling more traffic" end up near each other, even though they share no keywords. That's the magic of semantic search.

## Verify NumPy is Available

The background script pre-installed NumPy for vector math:

```bash
python3 -c "import numpy as np; print(f'NumPy {np.__version__} ready for vector operations')"
```{{exec}}

## Create the Vector RAG Application

This is the real deal - a complete vector RAG pipeline:

```bash
cat <<'PYEOF' > /root/workshop/rag-app/vector-rag.py
#!/usr/bin/env python3
"""
Vector RAG using Ollama Embeddings API
Production-grade pattern, minimal dependencies (numpy + urllib only)
"""
import json, os, sys, subprocess
import numpy as np
from urllib.request import urlopen, Request
from urllib.error import URLError

DOCS_DIR = "/root/workshop/rag-app/documents"
EMBEDDINGS_FILE = "/root/workshop/rag-app/embeddings.json"
OLLAMA_URL = "http://localhost:11434"

def get_embedding(text):
    """Get embedding vector from Ollama API"""
    text = text[:500]  # Limit text length for efficiency
    try:
        data = json.dumps({"model": "all-minilm", "input": text}).encode('utf-8')
        req = Request(f"{OLLAMA_URL}/api/embed", data=data,
                     headers={'Content-Type': 'application/json'})
        with urlopen(req, timeout=60) as response:
            result = json.loads(response.read().decode('utf-8'))
            embeddings = result.get("embeddings", [])
            if embeddings and len(embeddings) > 0:
                return embeddings[0]
        return []
    except URLError:
        print("  Connection error - is port-forward running?")
        print("  Run: kubectl port-forward svc/ollama -n ai-workshop 11434:11434 &")
        return []

def cosine_similarity(a, b):
    """Cosine similarity: dot(a,b) / (|a| * |b|)"""
    a, b = np.array(a), np.array(b)
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

def index_documents():
    """Create embeddings for all documents (one-time)"""
    print("INDEXING DOCUMENTS")
    print("=" * 50)
    embeddings = {}

    for filename in sorted(os.listdir(DOCS_DIR)):
        if not filename.endswith('.txt'):
            continue
        filepath = os.path.join(DOCS_DIR, filename)
        with open(filepath, 'r') as f:
            content = f.read()

        print(f"  Embedding: {filename}...", end=" ", flush=True)
        embedding = get_embedding(content)

        if embedding:
            embeddings[filename] = {
                "content": content,
                "embedding": embedding
            }
            print(f"({len(embedding)} dimensions)")
        else:
            print("FAILED")

    if embeddings:
        with open(EMBEDDINGS_FILE, 'w') as f:
            json.dump(embeddings, f)
        print(f"\nIndexed {len(embeddings)} documents -> {EMBEDDINGS_FILE}")
    else:
        print("\nNo documents indexed! Check port-forward and all-minilm model.")
    return embeddings

def load_embeddings():
    """Load pre-computed embeddings or create them"""
    if os.path.exists(EMBEDDINGS_FILE):
        with open(EMBEDDINGS_FILE, 'r') as f:
            return json.load(f)
    return index_documents()

def semantic_search(query, embeddings):
    """Find the most semantically similar document"""
    query_embedding = get_embedding(query)
    if not query_embedding:
        return None, None, []

    results = []
    for filename, data in embeddings.items():
        score = cosine_similarity(query_embedding, data["embedding"])
        results.append((filename, score))

    results.sort(key=lambda x: x[1], reverse=True)
    return results[0][0], results[0][1], results

def ask_ollama(prompt):
    """Send prompt to Ollama via kubectl"""
    result = subprocess.run(
        ["kubectl", "exec", "-i", "deployment/ollama",
         "-n", "ai-workshop", "--", "ollama", "run", "tinyllama"],
        input=prompt, text=True, capture_output=True, timeout=120
    )
    return result.stdout.strip()

def rag_query(question):
    """Full RAG pipeline: embed -> search -> augment -> generate"""
    embeddings = load_embeddings()

    print(f"VECTOR RAG QUERY")
    print(f"=" * 50)
    print(f"Q: {question}\n")

    # Semantic search
    print("Semantic search results:")
    best_doc, score, all_results = semantic_search(question, embeddings)

    if not all_results:
        print("Search failed. Check port-forward.")
        return

    for filename, sim in all_results:
        bar = "#" * int(sim * 30)
        marker = " <-- BEST" if filename == best_doc else ""
        print(f"  {filename:<30} {sim:.4f} {bar}{marker}")

    if best_doc and score > 0.1:
        print(f"\nUsing: {best_doc} (similarity: {score:.4f})")
        # Truncate context for faster LLM generation on CPU
        context = embeddings[best_doc]["content"][:600]

        prompt = f"""Answer concisely based on this context.

Context: {context}

Question: {question}
Answer in 2-3 sentences:"""

        print("Generating grounded answer...\n---")
        answer = ask_ollama(prompt)
        print(answer)
    else:
        print("\nNo relevant documents found (threshold: 0.1)")
        print("Asking without context (may hallucinate)...")
        print("---")
        print(ask_ollama(question))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python3 vector-rag.py index          # Index documents")
        print("  python3 vector-rag.py 'question'     # Ask with RAG")
        sys.exit(0)

    if sys.argv[1] == "index":
        index_documents()
    else:
        question = " ".join(sys.argv[1:])
        rag_query(question)
PYEOF

chmod +x /root/workshop/rag-app/vector-rag.py
echo "Vector RAG application created!"
```{{exec}}

## Index All Documents

This creates embedding vectors for each document (one-time operation):

```bash
python3 /root/workshop/rag-app/vector-rag.py index
```{{exec}}

> **What just happened?** Each document was sent through the `all-minilm` neural network, which read the text and outputted 384 numbers representing its meaning. "kubernetes-scaling.txt" became a vector like `[0.12, -0.34, ...]`. These vectors are saved to `embeddings.json` - a simple file-based vector store. In production, you'd use a dedicated vector database (Qdrant, Pinecone) that can handle millions of documents with fast approximate search.

## Test Vector RAG - The Magic Moment

Let's start with a query that clearly demonstrates semantic understanding:

```bash
# GPU sharing - natural language, finds the right document
python3 /root/workshop/rag-app/vector-rag.py "How can multiple teams share a single GPU?"
```{{exec}}

Look at the similarity scores! The GPU document scores much higher than others because the **meaning** matches, even if the exact words differ.

## More Semantic Queries

```bash
# Security question - different words, same meaning
python3 /root/workshop/rag-app/vector-rag.py "How do I protect my cluster from unauthorized access?"
```{{exec}}

```bash
# HPA question - grounded in actual documentation
python3 /root/workshop/rag-app/vector-rag.py "What is HPA and what kubectl command creates one?"
```{{exec}}

```bash
# This is about scaling but uses NONE of the scaling keywords!
python3 /root/workshop/rag-app/vector-rag.py "My website is overwhelmed with requests what should I do"
```{{exec}}

> Notice the similarity scores: even if the top score is modest (0.15-0.50), vector search still ranks the **correct document first**. That's the power of semantic search - it understands meaning, not just keywords.

## Compare: Keyword vs Vector

```bash
echo "=== KEYWORD RAG ==="
echo "(keyword matching - may find wrong document or nothing)"
/root/workshop/rag-app/simple-rag.sh "My website is overwhelmed what should I do"
echo ""
echo ""
echo "=== VECTOR RAG ==="
echo "(semantic search - understands meaning)"
python3 /root/workshop/rag-app/vector-rag.py "My website is overwhelmed what should I do"
```{{exec}}

## Why This Matters for Production

What you just built is the exact same pattern used in production RAG systems:

| Workshop Component      | Production Equivalent              |
|-------------------------|------------------------------------|
| `all-minilm` (23M)     | `text-embedding-3-large` or `bge-large` |
| JSON file store         | Qdrant, Pinecone, ChromaDB, pgvector |
| 4 documents             | Millions of documents with chunking |
| NumPy cosine similarity | HNSW/IVF approximate nearest neighbor |
| Single Ollama pod       | GPU-accelerated inference cluster  |

> **Challenge**: Try adding your own document! Create a new `.txt` file in `/root/workshop/rag-app/documents/`, then re-run `python3 /root/workshop/rag-app/vector-rag.py index` and query it.

## Step Summary

- Pulled `all-minilm` embedding model (23M parameters, 45MB)
- Created vector embeddings for all documents (384 dimensions each)
- Built a full vector RAG pipeline: embed -> cosine similarity -> augment -> generate
- Proved semantic search understands **meaning**, not just keywords
- Same pattern scales to production with GPU + vector databases

**Next: Let's isolate these AI workloads for different teams using vCluster!**
