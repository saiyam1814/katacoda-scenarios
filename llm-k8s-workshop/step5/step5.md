# Interact with the LLM

Now that our Ollama service is exposed, let's interact with the TinyLlama model by asking various questions and exploring its capabilities.

## Test Basic Questions

Let's start with some basic questions:

```bash
# Question 1: About Kubernetes
echo "Question: What is Kubernetes?"
/root/workspace/llm-workshop/ask-ollama.sh "What is Kubernetes?"
echo
```{{exec}}

```bash
# Question 2: About containers
echo "Question: What are containers?"
/root/workspace/llm-workshop/ask-ollama.sh "What are containers?"
echo
```{{exec}}

## Test Technical Questions

Let's try some more technical questions:

```bash
# Question 3: About pods
echo "Question: What is a Kubernetes pod?"
/root/workspace/llm-workshop/ask-ollama.sh "What is a Kubernetes pod?"
echo
```{{exec}}

```bash
# Question 4: About deployments
echo "Question: How do Kubernetes deployments work?"
/root/workspace/llm-workshop/ask-ollama.sh "How do Kubernetes deployments work?"
echo
```{{exec}}

## Test Creative Tasks

Let's see how the model handles creative tasks:

```bash
# Question 5: Creative writing
echo "Question: Write a haiku about cloud computing"
/root/workspace/llm-workshop/ask-ollama.sh "Write a haiku about cloud computing"
echo
```{{exec}}

## Direct CLI Interaction

You can also interact directly with the model using Ollama CLI:

```bash
# Ask a question directly
echo "Explain microservices in one sentence" | kubectl exec -i deployment/ollama-server -n llm-workshop -- ollama run tinyllama
```{{exec}}

## Understanding LLM Responses

When interacting with LLMs, keep in mind:

### **Strengths:**
- General knowledge questions
- Text generation and completion
- Simple reasoning tasks
- Creative writing

### **Limitations:**
- May generate incorrect information (hallucinations)
- Limited knowledge cutoff date
- May not have domain-specific knowledge
- Responses can be verbose or repetitive

### **Best Practices:**
- Ask clear, specific questions
- Provide context when needed
- Verify important information
- Use RAG for domain-specific knowledge (we'll do this next!)

## Test Different Question Types

Let's try a few more question types:

```bash
# Question 6: Comparison
echo "Question: Compare Docker and Kubernetes"
/root/workspace/llm-workshop/ask-ollama.sh "Compare Docker and Kubernetes in brief"
echo
```{{exec}}

```bash
# Question 7: How-to question
echo "Question: How do I scale a deployment in Kubernetes?"
/root/workspace/llm-workshop/ask-ollama.sh "How do I scale a deployment in Kubernetes?"
echo
```{{exec}}

## Monitor Performance

Let's check how the model is performing:

```bash
# Check pod status
kubectl get pods -n llm-workshop

# Check pod logs for any issues
kubectl logs -l app=ollama-server -n llm-workshop --tail=10
```{{exec}}

## Understanding Model Limitations

**TinyLlama (1.1B)** is a small model, so:
- ✅ Fast responses
- ✅ Low memory usage
- ✅ Good for learning
- ⚠️ Limited knowledge
- ⚠️ May produce less accurate answers
- ⚠️ Shorter context window

For production, you might want:
- **Larger models** (7B, 13B, 70B) for better quality
- **Fine-tuned models** for specific domains
- **RAG systems** to add domain knowledge (next step!)

## Create a Question Bank

Let's create a file with example questions you can try:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/questions.txt
What is Kubernetes?
What are the main components of Kubernetes?
How does a Kubernetes pod work?
What is the difference between a deployment and a replica set?
How do you scale applications in Kubernetes?
What is a Kubernetes service?
Explain Kubernetes namespaces
What are ConfigMaps and Secrets?
How does Kubernetes handle rolling updates?
What is container orchestration?
EOF

echo "📝 Question bank created. Try asking these:"
cat /root/workspace/llm-workshop/questions.txt
```{{exec}}

## Interaction Summary

We've successfully:
- ✅ Interacted with the TinyLlama model
- ✅ Tested various question types
- ✅ Explored model capabilities and limitations
- ✅ Created helper scripts for easier interaction
- ✅ Monitored model performance

## What's Next?

In the next step, we'll build a **RAG (Retrieval-Augmented Generation)** application that can answer questions based on specific documents. This will improve accuracy and enable domain-specific knowledge!

---

**Enjoyed interacting with the model?** Let's build something more powerful! 🚀
