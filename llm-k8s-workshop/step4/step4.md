# Expose the LLM Service

Now that we have Ollama running with TinyLlama, let's expose the service so we can interact with it more easily using port forwarding.

## Understanding Service Exposure

In Kubernetes, there are several ways to expose services:

1. **ClusterIP** (default) - Only accessible within the cluster
2. **NodePort** - Exposes service on each node's IP at a static port
3. **LoadBalancer** - Exposes service externally using a cloud provider's load balancer
4. **Port Forwarding** - Direct access to a pod/service (for development/testing)

For this workshop, we'll use **port forwarding** for easy access.

## Check Current Service

Let's see our current service configuration:

```bash
kubectl get svc ollama-service -n llm-workshop
kubectl describe svc ollama-service -n llm-workshop
```{{exec}}

## Create Port Forward

Let's create a port forward to access Ollama:

```bash
# Start port forward in the background
kubectl port-forward svc/ollama-service 11434:11434 -n llm-workshop &
sleep 2

# Verify port forward is running
ps aux | grep "kubectl port-forward" | grep -v grep
```{{exec}}

## Test Direct Access

Now let's test accessing Ollama directly via the port forward:

```bash
# Test Ollama API endpoint - list models
curl http://localhost:11434/api/tags

# Test with a simple prompt using the API
curl http://localhost:11434/api/generate -d '{
  "model": "tinyllama",
  "prompt": "What is Kubernetes?",
  "stream": false
}'
```{{exec}}

## Understanding Port Forwarding

**Port Forwarding** allows you to:
- Access services that are only available inside the cluster
- Test services during development
- Debug issues without changing service configuration
- Use local tools to interact with cluster services

**How it works:**
1. `kubectl port-forward` creates a secure tunnel
2. Traffic from your local machine is forwarded to the pod/service
3. The connection is encrypted and secure
4. When you close the port-forward, access is removed

## Create a Helper Script

Let's create a script to easily interact with Ollama via the API:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/ask-ollama.sh
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 'Your question here'"
    exit 1
fi

QUESTION="$1"

echo "🤖 Asking Ollama: $QUESTION"
echo "============================"
echo

curl -s http://localhost:11434/api/generate -d "{
  \"model\": \"tinyllama\",
  \"prompt\": \"$QUESTION\",
  \"stream\": false
}" | grep -o '"response":"[^"]*"' | sed 's/"response":"//;s/"$//' | sed 's/\\n/\n/g'

echo
EOF

chmod +x /root/workspace/llm-workshop/ask-ollama.sh
```{{exec}}

## Test the Helper Script

```bash
# Test the helper script
/root/workspace/llm-workshop/ask-ollama.sh "What is container orchestration?"
```{{exec}}

## Verify Service Accessibility

Let's verify everything is working:

```bash
# Check if port forward is still running
pgrep -f "kubectl port-forward.*ollama-service"

# Test connectivity
curl -s http://localhost:11434/api/tags
```{{exec}}

## Service Exposure Summary

We've successfully:
- ✅ Created port forwarding to access Ollama
- ✅ Tested direct API access
- ✅ Created helper scripts for easier interaction
- ✅ Verified the service is accessible

## Understanding Kubernetes Services

**Services** in Kubernetes provide:
- **Stable IP address** - Even when pods restart
- **Load balancing** - Distribute traffic across pod replicas
- **Service discovery** - Find services by name
- **Abstraction** - Hide pod details from consumers

Our `ollama-service`:
- Type: ClusterIP (internal access)
- Port: 11434 (Ollama's default port)
- Selector: `app=ollama-server` (routes to our Ollama pods)

## What's Next?

In the next step, we'll interact with the model by asking various questions and exploring its capabilities!

---

**Service exposed?** Let's ask some questions! 🚀
