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
- Uses an LLM (our vLLM service) to generate a response
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

1. **User asks a question** → "What is a Kubernetes pod?"
2. **Retrieval** → Search documents for relevant information about "pod"
3. **Augmentation** → Combine question with retrieved context
4. **Generation** → Send augmented prompt to vLLM
5. **Response** → Return answer based on document knowledge

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
- ConfigMaps: Store configuration data as key-value pairs. ConfigMaps can be mounted as files or environment variables.
- Secrets: Store sensitive data like passwords and API keys. Secrets are base64 encoded and can be mounted similarly to ConfigMaps.

Kubernetes provides features like:
- Automatic scaling based on CPU/memory usage
- Self-healing by restarting failed containers
- Service discovery through DNS
- Load balancing across pod replicas
- Rolling updates with zero downtime
- Resource management and quotas
EOF

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-scaling.txt
Kubernetes Scaling Strategies

Kubernetes provides multiple ways to scale applications:

1. Horizontal Pod Autoscaler (HPA)
   - Scale based on CPU/memory usage
   - Custom metrics scaling
   - Scheduled scaling
   - Automatically adjusts the number of pod replicas

2. Vertical Pod Autoscaler (VPA)
   - Adjust resource requests/limits
   - Right-size containers
   - Reduce resource waste
   - Automatically sets CPU and memory requests

3. Cluster Autoscaler
   - Add/remove nodes based on demand
   - Cost optimization
   - Multi-zone scaling
   - Works with cloud providers

4. Manual Scaling
   - kubectl scale command
   - Update deployment replicas
   - Immediate scaling
   - kubectl scale deployment/myapp --replicas=5

Best Practices:
- Set appropriate resource requests and limits
- Use multiple metrics for scaling decisions
- Test scaling behavior under load
- Monitor scaling events and performance
EOF

cat <<'EOF' > /root/workspace/llm-workshop/rag-app/documents/kubernetes-security.txt
Kubernetes Security Best Practices

Security is crucial in Kubernetes environments. Here are key security practices:

1. RBAC (Role-Based Access Control)
   - Define roles and permissions
   - Use least privilege principle
   - Regular access reviews
   - Limit who can do what

2. Network Policies
   - Control traffic between pods
   - Implement network segmentation
   - Use service mesh for advanced networking
   - Restrict ingress and egress

3. Pod Security
   - Run containers as non-root
   - Use read-only root filesystems
   - Drop unnecessary capabilities
   - Apply security contexts

4. Image Security
   - Scan images for vulnerabilities
   - Use trusted base images
   - Implement image signing
   - Regular image updates

5. Secrets Management
   - Use Kubernetes secrets or external secret managers
   - Encrypt secrets at rest
   - Rotate secrets regularly
   - Never commit secrets to git

6. Monitoring and Auditing
   - Enable audit logging
   - Monitor for suspicious activities
   - Use security scanning tools
   - Regular security assessments
EOF
```{{exec}}

## Deploy RAG Application

Let's create and deploy the RAG application that uses our vLLM service:

```bash
# Create the RAG app deployment manifest
cat <<EOF > /root/workspace/llm-workshop/rag-app-deployment.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rag-app-code
  namespace: llm-workshop
data:
  rag_app.py: |
    #!/usr/bin/env python3
    import os
    import json
    import requests
    from flask import Flask, request, jsonify
    import re
    from collections import Counter
    import math

    app = Flask(__name__)

    class SimpleRAG:
        def __init__(self, documents_dir):
            self.documents_dir = documents_dir
            self.documents = {}
            self.load_documents()
        
        def load_documents(self):
            """Load all documents from the documents directory"""
            for filename in os.listdir(self.documents_dir):
                if filename.endswith('.txt'):
                    filepath = os.path.join(self.documents_dir, filename)
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                        self.documents[filename] = content
                        print(f"Loaded document: {filename}")
        
        def simple_tokenize(self, text):
            """Simple tokenization"""
            return re.findall(r'\b\w+\b', text.lower())
        
        def calculate_tf_idf(self, query, document):
            """Calculate TF-IDF score for query against document"""
            query_tokens = self.simple_tokenize(query)
            doc_tokens = self.simple_tokenize(document)
            
            if not query_tokens or not doc_tokens:
                return 0
            
            # Calculate term frequency for query terms in document
            doc_token_count = Counter(doc_tokens)
            tf_score = 0
            for term in query_tokens:
                if term in doc_tokens:
                    tf = doc_token_count[term] / len(doc_tokens)
                    tf_score += tf
            
            # Simple IDF calculation
            idf_score = math.log(len(self.documents) / (1 + sum(1 for doc in self.documents.values() if any(term in doc.lower() for term in query_tokens))))
            
            return tf_score * idf_score
        
        def retrieve_relevant_docs(self, query, top_k=2):
            """Retrieve most relevant documents for the query"""
            scores = {}
            for filename, content in self.documents.items():
                score = self.calculate_tf_idf(query, content)
                scores[filename] = score
            
            # Sort by score and return top_k documents
            sorted_docs = sorted(scores.items(), key=lambda x: x[1], reverse=True)
            return sorted_docs[:top_k]
        
        def get_llm_response(self, prompt):
            """Get response from vLLM using OpenAI-compatible API"""
            url = "http://vllm-service.llm-workshop.svc.cluster.local:8000/v1/completions"
            
            payload = {
                "model": "facebook/opt-125m",
                "prompt": prompt,
                "max_tokens": 200,
                "temperature": 0.7
            }
            
            try:
                response = requests.post(url, json=payload, timeout=30)
                response.raise_for_status()
                return response.json()["choices"][0]["text"]
            except Exception as e:
                return f"Error: {str(e)}"
        
        def answer_question(self, question):
            """Answer a question using RAG"""
            # Retrieve relevant documents
            relevant_docs = self.retrieve_relevant_docs(question)
            
            # Build context from relevant documents
            context = ""
            for filename, score in relevant_docs:
                if score > 0:  # Only include documents with positive scores
                    context += f"\n--- {filename} (relevance: {score:.3f}) ---\n"
                    context += self.documents[filename]
                    context += "\n"
            
            # Create prompt with context
            prompt = f"""Based on the following context about Kubernetes, answer the question: {question}

Context:
{context}

Answer the question based on the provided context. If the context doesn't contain enough information, say so."""

            # Get LLM response
            response = self.get_llm_response(prompt)
            
            return {
                "answer": response,
                "relevant_docs": [{"filename": filename, "score": score} for filename, score in relevant_docs],
                "context_used": context
            }

    # Initialize RAG system
    rag = SimpleRAG("/app/documents")

    @app.route('/')
    def index():
        return '''
        <!DOCTYPE html>
        <html>
        <head>
            <title>Kubernetes RAG Assistant</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
                .container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                .chat-box { border: 1px solid #ddd; padding: 20px; margin: 20px 0; border-radius: 5px; background-color: #f9f9f9; }
                .input-group { display: flex; margin: 20px 0; }
                input[type="text"] { flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 5px 0 0 5px; }
                button { padding: 10px 20px; background-color: #28a745; color: white; border: none; border-radius: 0 5px 5px 0; cursor: pointer; }
                button:hover { background-color: #218838; }
                .response { background-color: #e7f3ff; padding: 15px; border-radius: 5px; margin-top: 10px; }
                .sources { background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-top: 10px; font-size: 0.9em; }
                h1 { color: #333; text-align: center; }
                .example-questions { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; }
                .example-questions h3 { margin-top: 0; }
                .example-questions button { background-color: #6c757d; margin: 5px; padding: 5px 10px; border-radius: 3px; font-size: 0.9em; }
                .example-questions button:hover { background-color: #5a6268; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🤖 Kubernetes RAG Assistant</h1>
                <p>Ask questions about Kubernetes and get answers based on our knowledge base!</p>
                
                <div class="example-questions">
                    <h3>Try these example questions:</h3>
                    <button onclick="askQuestion('What is a Kubernetes pod?')">What is a Kubernetes pod?</button>
                    <button onclick="askQuestion('How do I scale applications in Kubernetes?')">How do I scale applications?</button>
                    <button onclick="askQuestion('What are Kubernetes security best practices?')">Security best practices?</button>
                    <button onclick="askQuestion('How does HPA work?')">How does HPA work?</button>
                </div>
                
                <div class="chat-box">
                    <h3>Ask your question:</h3>
                    <form id="chatForm">
                        <div class="input-group">
                            <input type="text" id="question" placeholder="Enter your Kubernetes question..." required>
                            <button type="submit">Ask</button>
                        </div>
                    </form>
                    <div id="response" class="response" style="display: none;"></div>
                    <div id="sources" class="sources" style="display: none;"></div>
                </div>
            </div>
            
            <script>
                document.getElementById('chatForm').addEventListener('submit', async function(e) {
                    e.preventDefault();
                    const question = document.getElementById('question').value;
                    await askQuestion(question);
                });
                
                async function askQuestion(question) {
                    document.getElementById('question').value = question;
                    const responseDiv = document.getElementById('response');
                    const sourcesDiv = document.getElementById('sources');
                    
                    responseDiv.style.display = 'block';
                    sourcesDiv.style.display = 'block';
                    responseDiv.innerHTML = 'Thinking...';
                    sourcesDiv.innerHTML = '';
                    
                    try {
                        const response = await fetch('/ask', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ question: question })
                        });
                        
                        const data = await response.json();
                        responseDiv.innerHTML = data.answer;
                        
                        if (data.relevant_docs && data.relevant_docs.length > 0) {
                            sourcesDiv.innerHTML = '<strong>Sources used:</strong><br>' + 
                                data.relevant_docs.map(doc => \`\${doc.filename} (relevance: \${doc.score.toFixed(3)})\`).join('<br>');
                        }
                    } catch (error) {
                        responseDiv.innerHTML = 'Error: ' + error.message;
                    }
                }
            </script>
        </body>
        </html>
        '''

    @app.route('/ask', methods=['POST'])
    def ask():
        data = request.get_json()
        question = data.get('question', '')
        result = rag.answer_question(question)
        return jsonify(result)

    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=5001, debug=True)
---
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
    - Pods: The smallest deployable units in Kubernetes. A pod can contain one or more containers that share storage and network resources.
    - Services: Stable network endpoints for pods. Services provide a way to access pods using a consistent IP address and DNS name.
    - Deployments: Manage replica sets and rolling updates. Deployments ensure a specified number of pod replicas are running.
    - Namespaces: Virtual clusters within a physical cluster. Namespaces help organize and isolate resources.
    - ConfigMaps: Store configuration data as key-value pairs. ConfigMaps can be mounted as files or environment variables.
    - Secrets: Store sensitive data like passwords and API keys. Secrets are base64 encoded and can be mounted similarly to ConfigMaps.

    Kubernetes provides features like:
    - Automatic scaling based on CPU/memory usage
    - Self-healing by restarting failed containers
    - Service discovery through DNS
    - Load balancing across pod replicas
    - Rolling updates with zero downtime
    - Resource management and quotas
  kubernetes-scaling.txt: |
    Kubernetes Scaling Strategies

    Kubernetes provides multiple ways to scale applications:

    1. Horizontal Pod Autoscaler (HPA)
       - Scale based on CPU/memory usage
       - Custom metrics scaling
       - Scheduled scaling
       - Automatically adjusts the number of pod replicas

    2. Vertical Pod Autoscaler (VPA)
       - Adjust resource requests/limits
       - Right-size containers
       - Reduce resource waste
       - Automatically sets CPU and memory requests

    3. Cluster Autoscaler
       - Add/remove nodes based on demand
       - Cost optimization
       - Multi-zone scaling
       - Works with cloud providers

    4. Manual Scaling
       - kubectl scale command
       - Update deployment replicas
       - Immediate scaling
       - kubectl scale deployment/myapp --replicas=5

    Best Practices:
    - Set appropriate resource requests and limits
    - Use multiple metrics for scaling decisions
    - Test scaling behavior under load
    - Monitor scaling events and performance
  kubernetes-security.txt: |
    Kubernetes Security Best Practices

    Security is crucial in Kubernetes environments. Here are key security practices:

    1. RBAC (Role-Based Access Control)
       - Define roles and permissions
       - Use least privilege principle
       - Regular access reviews
       - Limit who can do what

    2. Network Policies
       - Control traffic between pods
       - Implement network segmentation
       - Use service mesh for advanced networking
       - Restrict ingress and egress

    3. Pod Security
       - Run containers as non-root
       - Use read-only root filesystems
       - Drop unnecessary capabilities
       - Apply security contexts

    4. Image Security
       - Scan images for vulnerabilities
       - Use trusted base images
       - Implement image signing
       - Regular image updates

    5. Secrets Management
       - Use Kubernetes secrets or external secret managers
       - Encrypt secrets at rest
       - Rotate secrets regularly
       - Never commit secrets to git

    6. Monitoring and Auditing
       - Enable audit logging
       - Monitor for suspicious activities
       - Use security scanning tools
       - Regular security assessments
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
        - name: app-code
          mountPath: /app
        - name: documents
          mountPath: /app/documents
      volumes:
      - name: app-code
        configMap:
          name: rag-app-code
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
kubectl apply -f /root/workspace/llm-workshop/rag-app-deployment.yaml
```{{exec}}

## Wait for RAG App to be Ready

```bash
kubectl wait --for=condition=ready pod -l app=rag-app -n llm-workshop --timeout=180s
```{{exec}}

## Expose RAG Application

Let's create a port forward to access the RAG application:

```bash
# Start port forward for RAG app
kubectl port-forward svc/rag-app-service 5001:5001 -n llm-workshop &
sleep 2

# Verify port forward is running
ps aux | grep "kubectl port-forward.*rag-app" | grep -v grep
```{{exec}}

## Test the RAG Application

Let's test the RAG application:

```bash
# Test the RAG API
curl -X POST http://localhost:5001/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "What is a Kubernetes pod?"}' | python3 -m json.tool || \
curl -X POST http://localhost:5001/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "What is a Kubernetes pod?"}'
```{{exec}}

## Access the Web Interface

The RAG application includes a web interface! You can access it at:

```
http://localhost:5001
```

Try asking questions like:
- "What is a Kubernetes pod?"
- "How do I scale applications in Kubernetes?"
- "What are Kubernetes security best practices?"
- "How does HPA work?"

## Understanding the RAG Application Architecture

Our RAG application consists of:

1. **Document Store** (ConfigMap)
   - Contains Kubernetes knowledge base documents
   - Loaded into the application at startup

2. **Retrieval System** (TF-IDF)
   - Calculates relevance scores for documents
   - Returns top-k most relevant documents
   - Simple but effective for small document sets

3. **Augmentation**
   - Combines user question with retrieved context
   - Creates a prompt that includes both question and relevant information

4. **Generation** (vLLM Service)
   - Sends augmented prompt to vLLM
   - Uses OpenAI-compatible API
   - Returns answer based on context

5. **Web Interface**
   - Flask web application
   - Simple HTML/CSS/JavaScript frontend
   - Shows answer and source documents

## RAG Application Summary

We've successfully built:
- ✅ A document-based knowledge base (3 Kubernetes documents)
- ✅ A simple TF-IDF retrieval system
- ✅ A RAG application that combines retrieval and generation
- ✅ Integration with our vLLM service using OpenAI-compatible API
- ✅ A web interface for easy interaction
- ✅ Source attribution (shows which documents were used)

## Key Takeaways

**RAG improves LLM applications by:**
- Providing accurate, document-grounded answers
- Reducing hallucinations
- Enabling domain-specific knowledge
- Allowing knowledge base updates without retraining
- Providing transparency (shows sources)

**For production, consider:**
- Vector databases (Pinecone, Weaviate, Qdrant) for better retrieval
- Embedding models for semantic search
- More sophisticated chunking strategies
- Caching for frequently asked questions
- Authentication and rate limiting

## What's Next?

Congratulations! You've completed the workshop. You've learned how to:
- Deploy vLLM with CPU mode on Kubernetes
- Run LLM models in a cloud-native environment
- Build RAG applications for accurate, context-aware responses
- Understand how to scale and optimize LLM workloads

---

**RAG application working?** Great job completing the workshop! 🎉
