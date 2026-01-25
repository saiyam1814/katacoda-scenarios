# Build a RAG Application

Now let's build a Retrieval-Augmented Generation (RAG) application that can answer questions based on specific documents. This is a powerful pattern for creating AI applications that can access and use specific knowledge.

## Understanding RAG

RAG (Retrieval-Augmented Generation) is a technique that combines:

### 🔍 **Retrieval**
- Searches through a knowledge base (documents, databases)
- Finds the most relevant information for a user's question
- Uses techniques like semantic search, keyword matching, or vector similarity
- In our simple implementation, we use TF-IDF (Term Frequency-Inverse Document Frequency)

### 🔗 **Augmentation** 
- Takes the user's original question
- Adds the retrieved context to provide more information
- Creates a richer prompt for the LLM
- The LLM receives: Question + Relevant Context

### 🤖 **Generation**
- Uses an LLM (our Ollama service) to generate a response
- The LLM has access to both the question AND the relevant context
- Produces more accurate and contextual answers
- Reduces hallucinations by grounding answers in real documents

## Why RAG is Important

- **Accuracy**: LLMs can "hallucinate" or make up information. RAG provides real facts from documents.
- **Up-to-date**: Knowledge base can be updated without retraining the LLM
- **Domain-specific**: Can work with specialized documents (company docs, technical manuals, knowledge bases)
- **Cost-effective**: Don't need to retrain large models for new information
- **Transparency**: Can show which documents were used to answer the question

## How Our RAG Application Works

```
┌─────────────────────────────────────────────────────────────┐
│                    RAG Application Flow                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. User Question ──► "What is a Kubernetes pod?"           │
│         │                                                    │
│         ▼                                                    │
│  2. Retrieval ──► Search documents for "pod" keywords       │
│         │         (TF-IDF scoring)                          │
│         ▼                                                    │
│  3. Augmentation ──► Combine question + retrieved context   │
│         │                                                    │
│         ▼                                                    │
│  4. Generation ──► Send to Ollama/TinyLlama                 │
│         │                                                    │
│         ▼                                                    │
│  5. Response ──► Answer grounded in document knowledge      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Create Sample Documents

Let's create some sample documents about Kubernetes:

```bash
mkdir -p /root/workspace/llm-workshop/rag-app/documents

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-basics.txt
Kubernetes Basics

Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It was originally designed by Google and is now maintained by the Cloud Native Computing Foundation.

Key Concepts:
- Pods: The smallest deployable units in Kubernetes. A pod can contain one or more containers that share storage and network resources.
- Services: Stable network endpoints for pods. Services provide a way to access pods using a consistent IP address and DNS name.
- Deployments: Manage replica sets and rolling updates. Deployments ensure a specified number of pod replicas are running.
- Namespaces: Virtual clusters within a physical cluster. Namespaces help organize and isolate resources.
- ConfigMaps: Store configuration data as key-value pairs.
- Secrets: Store sensitive data like passwords and API keys.

Kubernetes provides features like:
- Automatic scaling based on CPU/memory usage
- Self-healing by restarting failed containers
- Service discovery through DNS
- Load balancing across pod replicas
- Rolling updates with zero downtime
EOF

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-scaling.txt
Kubernetes Scaling Strategies

Kubernetes provides multiple ways to scale applications:

1. Horizontal Pod Autoscaler (HPA)
   - Scale based on CPU/memory usage
   - Custom metrics scaling
   - Automatically adjusts the number of pod replicas
   - Example: kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=50

2. Vertical Pod Autoscaler (VPA)
   - Adjust resource requests/limits
   - Right-size containers automatically
   - Reduce resource waste

3. Cluster Autoscaler
   - Add/remove nodes based on demand
   - Works with cloud providers
   - Cost optimization through scaling

4. Manual Scaling
   - kubectl scale command
   - Update deployment replicas directly
   - Example: kubectl scale deployment/myapp --replicas=5

Best Practices:
- Set appropriate resource requests and limits
- Use multiple metrics for scaling decisions
- Test scaling behavior under load
EOF

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-security.txt
Kubernetes Security Best Practices

Security is crucial in Kubernetes environments. Here are key security practices:

1. RBAC (Role-Based Access Control)
   - Define roles and permissions
   - Use least privilege principle
   - Regular access reviews

2. Network Policies
   - Control traffic between pods
   - Implement network segmentation
   - Restrict ingress and egress

3. Pod Security
   - Run containers as non-root
   - Use read-only root filesystems
   - Drop unnecessary capabilities

4. Image Security
   - Scan images for vulnerabilities
   - Use trusted base images
   - Implement image signing

5. Secrets Management
   - Use Kubernetes secrets or external secret managers
   - Encrypt secrets at rest
   - Rotate secrets regularly
   - Never commit secrets to git
EOF

echo "✅ Created 3 knowledge base documents"
ls -la /root/workspace/llm-workshop/rag-app/documents/
```{{exec}}

## Create the RAG Application

Let's create a simple RAG application script:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/rag-app/simple-rag.sh
#!/bin/bash

# Simple RAG Application for Kubernetes Knowledge Base
# Uses TF-IDF-like keyword matching and Ollama for generation

DOCS_DIR="/root/workspace/llm-workshop/rag-app/documents"

# Function to search documents for relevant content
search_documents() {
    local query="$1"
    local best_doc=""
    local best_score=0
    
    # Convert query to lowercase for matching
    query_lower=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    
    # Search each document
    for doc in "$DOCS_DIR"/*.txt; do
        if [ -f "$doc" ]; then
            # Count keyword matches (simple TF-IDF approximation)
            score=0
            for word in $query_lower; do
                if [ ${#word} -gt 3 ]; then  # Only count words > 3 chars
                    matches=$(grep -oi "$word" "$doc" 2>/dev/null | wc -l)
                    score=$((score + matches))
                fi
            done
            
            if [ $score -gt $best_score ]; then
                best_score=$score
                best_doc="$doc"
            fi
        fi
    done
    
    if [ -n "$best_doc" ] && [ $best_score -gt 0 ]; then
        echo "$best_doc"
    else
        echo ""
    fi
}

# Main RAG function
ask_rag() {
    local question="$1"
    
    echo "🔍 Searching knowledge base..."
    relevant_doc=$(search_documents "$question")
    
    if [ -n "$relevant_doc" ]; then
        echo "📄 Found relevant document: $(basename "$relevant_doc")"
        context=$(cat "$relevant_doc")
        
        # Create augmented prompt
        prompt="Based on the following context about Kubernetes, answer this question: $question

Context:
$context

Please provide a concise answer based on the context above."
        
        echo "🤖 Generating answer..."
        echo "---"
        echo "$prompt" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
    else
        echo "⚠️  No relevant documents found. Asking without context..."
        echo "$question" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
    fi
}

# Check if question provided
if [ -z "$1" ]; then
    echo "🤖 Kubernetes RAG Assistant"
    echo "=========================="
    echo "Usage: $0 'Your question about Kubernetes'"
    echo ""
    echo "Example questions:"
    echo "  $0 'What is a Kubernetes pod?'"
    echo "  $0 'How do I scale applications?'"
    echo "  $0 'What are security best practices?'"
    exit 0
fi

ask_rag "$1"
EOF

chmod +x /root/workspace/llm-workshop/rag-app/simple-rag.sh
echo "✅ RAG application created"
```{{exec}}

## Test the RAG Application

Let's test our RAG application:

```bash
# Test 1: Question about pods (should find kubernetes-basics.txt)
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What is a Kubernetes pod?"
```{{exec}}

```bash
# Test 2: Question about scaling (should find kubernetes-scaling.txt)
/root/workspace/llm-workshop/rag-app/simple-rag.sh "How do I scale applications in Kubernetes?"
```{{exec}}

```bash
# Test 3: Question about security (should find kubernetes-security.txt)
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What are Kubernetes security best practices?"
```{{exec}}

## Compare RAG vs Direct Query

Let's see the difference between asking with and without RAG:

```bash
echo "=== WITHOUT RAG (Direct Question) ==="
echo "What is HPA in Kubernetes?" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama

echo ""
echo "=== WITH RAG (Using Knowledge Base) ==="
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What is HPA in Kubernetes?"
```{{exec}}

## Understanding the RAG Application Architecture

Our RAG application consists of:

### 1. **Document Store** (Text Files)
- Contains Kubernetes knowledge base documents
- Easy to add, update, or remove documents
- Located in `/root/workspace/llm-workshop/rag-app/documents/`

### 2. **Retrieval System** (Keyword Matching)
- Searches documents for relevant keywords
- Counts word frequency (simple TF-IDF)
- Returns the most relevant document

### 3. **Augmentation** (Prompt Engineering)
- Combines user question with retrieved context
- Creates a structured prompt for the LLM
- Instructs the model to use the provided context

### 4. **Generation** (Ollama/TinyLlama)
- Processes the augmented prompt
- Generates answer based on context
- Returns grounded response

## Add Your Own Documents

You can add your own documents to the knowledge base:

```bash
# Example: Add a document about networking
cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-networking.txt
Kubernetes Networking

Kubernetes networking enables communication between pods, services, and external clients.

Key Concepts:
- ClusterIP: Internal service accessible only within the cluster
- NodePort: Exposes service on each node's IP at a static port
- LoadBalancer: Exposes service externally using cloud load balancer
- Ingress: HTTP/HTTPS routing to services based on rules

Pod Networking:
- Each pod gets its own IP address
- Pods can communicate directly without NAT
- Containers in the same pod share network namespace

Service Discovery:
- DNS-based service discovery
- Services get DNS names like: service-name.namespace.svc.cluster.local
EOF

echo "✅ Added networking document"
ls /root/workspace/llm-workshop/rag-app/documents/
```{{exec}}

## Test with New Document

```bash
# Test with the new networking document
/root/workspace/llm-workshop/rag-app/simple-rag.sh "What is a Kubernetes Ingress?"
```{{exec}}

## RAG Application Summary

We've successfully built:
- ✅ A document-based knowledge base (4 Kubernetes documents)
- ✅ A simple keyword-based retrieval system
- ✅ A RAG application that combines retrieval and generation
- ✅ Integration with our Ollama/TinyLlama service
- ✅ Source attribution (shows which document was used)

## Key Takeaways

**RAG improves LLM applications by:**
- Providing accurate, document-grounded answers
- Reducing hallucinations
- Enabling domain-specific knowledge
- Allowing knowledge base updates without retraining
- Providing transparency (shows sources)

**For production, consider:**
- **Vector databases** (Pinecone, Weaviate, Qdrant) for better retrieval
- **Embedding models** for semantic search
- **More sophisticated chunking** strategies
- **Caching** for frequently asked questions
- **Web interface** for easier interaction

## Congratulations!

You've completed the workshop! You've learned how to:
- ✅ Deploy Ollama on Kubernetes
- ✅ Run LLM models in a cloud-native environment
- ✅ Build RAG applications for accurate, context-aware responses
- ✅ Understand how to scale and optimize LLM workloads

---

**RAG application working?** Great job completing the workshop! 🎉
