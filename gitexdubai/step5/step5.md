# Building a Simple RAG Application

Now let's build a Retrieval-Augmented Generation (RAG) application that can answer questions based on specific documents. This is a powerful pattern for creating AI applications that can access and use specific knowledge.

## Understanding RAG

RAG (Retrieval-Augmented Generation) is a technique that combines:

### 🔍 **Retrieval**
- Searches through a knowledge base (documents, databases)
- Finds the most relevant information for a user's question
- Uses techniques like semantic search, keyword matching, or vector similarity

### 🔗 **Augmentation** 
- Takes the user's original question
- Adds the retrieved context to provide more information
- Creates a richer prompt for the LLM

### 🤖 **Generation**
- Uses an LLM to generate a response
- The LLM has access to both the question AND the relevant context
- Produces more accurate and contextual answers

## Why RAG is Important

- **Accuracy**: LLMs can "hallucinate" or make up information. RAG provides real facts.
- **Up-to-date**: Knowledge base can be updated without retraining the LLM
- **Domain-specific**: Can work with specialized documents (company docs, technical manuals)
- **Cost-effective**: Don't need to retrain large models for new information

## Create Sample Documents

Let's create some sample documents about Kubernetes:

```bash
mkdir -p /root/workspace/llm-workshop/rag-app/documents

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-basics.txt
Kubernetes Basics

Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It was originally designed by Google and is now maintained by the Cloud Native Computing Foundation.

Key Concepts:
- Pods: The smallest deployable units in Kubernetes
- Services: Stable network endpoints for pods
- Deployments: Manage replica sets and rolling updates
- Namespaces: Virtual clusters within a physical cluster
- ConfigMaps: Store configuration data
- Secrets: Store sensitive data

Kubernetes provides features like:
- Automatic scaling
- Self-healing
- Service discovery
- Load balancing
- Rolling updates
- Resource management
EOF
```

## Deploy RAG Application

Let's create and deploy the RAG application:

```bash
# Create the RAG app deployment manifest
cat <<EOF > /home/rag-app-deployment.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rag-documents
  namespace: llm-workshop
data:
  kubernetes-basics.txt: |
    Kubernetes Basics

    Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It was originally designed by Google and is now maintained by the Cloud Native Computing Foundation.

    Key Concepts:
    - Pods: The smallest deployable units in Kubernetes
    - Services: Stable network endpoints for pods
    - Deployments: Manage replica sets and rolling updates
    - Namespaces: Virtual clusters within a physical cluster
    - ConfigMaps: Store configuration data
    - Secrets: Store sensitive data

    Kubernetes provides features like:
    - Automatic scaling
    - Self-healing
    - Service discovery
    - Load balancing
    - Rolling updates
    - Resource management
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rag-app
  namespace: llm-workshop
  labels:
    app: rag-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rag-app
  template:
    metadata:
      labels:
        app: rag-app
    spec:
      containers:
      - name: rag-app
        image: python:3.9-slim
        ports:
        - containerPort: 5001
        command: ["/bin/bash"]
        args: ["-c", "pip install flask requests && python /app/rag_app.py"]
        resources:
          requests:
            memory: "512Mi"
            cpu: "200m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        volumeMounts:
        - name: documents
          mountPath: /app/documents
      volumes:
      - name: documents
        configMap:
          name: rag-documents
---
apiVersion: v1
kind: Service
metadata:
  name: rag-app-service
  namespace: llm-workshop
spec:
  selector:
    app: rag-app
  ports:
  - port: 5001
    targetPort: 5001
  type: ClusterIP
EOF

# Deploy RAG application
kubectl apply -f /home/rag-app-deployment.yaml
```{{exec}}

## Wait for RAG App to be Ready

```bash
kubectl wait --for=condition=ready pod -l app=rag-app -n llm-workshop --timeout=120s
```{{exec}}

## Create a Simple RAG Application

Let's also create a basic RAG application for testing:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/rag-app/simple-rag.py
#!/usr/bin/env python3
import requests
import json
import re
from collections import Counter
import math

def simple_tokenize(text):
    """Simple tokenization"""
    return re.findall(r'\b\w+\b', text.lower())

def calculate_tf_idf(query, document):
    """Calculate TF-IDF score for query against document"""
    query_tokens = simple_tokenize(query)
    doc_tokens = simple_tokenize(document)
    
    if not query_tokens or not doc_tokens:
        return 0
    
    # Calculate term frequency
    doc_token_count = Counter(doc_tokens)
    tf_score = 0
    for term in query_tokens:
        if term in doc_tokens:
            tf = doc_token_count[term] / len(doc_tokens)
            tf_score += tf
    
    return tf_score

def get_llm_response(prompt):
    """Get response from LLM"""
    url = "http://localhost:8000/v1/completions"
    
    payload = {
        "model": "facebook/opt-125m",
        "prompt": prompt,
        "max_tokens": 150,
        "temperature": 0.7
    }
    
    try:
        response = requests.post(url, json=payload, timeout=30)
        response.raise_for_status()
        return response.json()["choices"][0]["text"]
    except Exception as e:
        return f"Error: {str(e)}"

def answer_question(question, documents):
    """Answer a question using RAG"""
    # Find most relevant document
    scores = {}
    for filename, content in documents.items():
        score = calculate_tf_idf(question, content)
        scores[filename] = score
    
    # Get the most relevant document
    best_doc = max(scores.items(), key=lambda x: x[1])
    
    if best_doc[1] > 0:
        context = best_doc[1]
        prompt = f"""Based on the following context about Kubernetes, answer the question: {question}

Context:
{context}

Answer the question based on the provided context."""
    else:
        prompt = f"Answer this question: {question}"
    
    response = get_llm_response(prompt)
    return response

# Load documents
documents = {}
with open('/root/workspace/llm-workshop/rag-app/documents/kubernetes-basics.txt', 'r') as f:
    documents['kubernetes-basics.txt'] = f.read()

# Test the RAG system
print("🤖 Kubernetes RAG Assistant")
print("Ask questions about Kubernetes!")

while True:
    question = input("\nEnter your question (or 'quit' to exit): ")
    if question.lower() == 'quit':
        break
    
    answer = answer_question(question, documents)
    print(f"\nAnswer: {answer}")
EOF

chmod +x /root/workspace/llm-workshop/rag-app/simple-rag.py
```

## Test the RAG Application

```bash
cd /root/workspace/llm-workshop/rag-app
python3 simple-rag.py
```

Try asking questions like:
- "What is a Kubernetes pod?"
- "How does Kubernetes handle scaling?"
- "What are the key concepts in Kubernetes?"

## RAG Application Summary

We've successfully built:
- ✅ A document-based knowledge base
- ✅ A simple TF-IDF retrieval system
- ✅ A RAG application that combines retrieval and generation
- ✅ Integration with our vLLM service

## What's Next?

In the next step, we'll explore multi-tenancy using vcluster to show how different teams can run their own LLM workloads in isolation!

---

**RAG working?** Let's explore multi-tenancy! 🚀
