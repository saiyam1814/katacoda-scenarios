# Expose the LLM Service

Now that we have vLLM running with OPT-125M, let's expose the service so we can interact with it from outside the cluster. We'll use port forwarding to make the service accessible.

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
kubectl get svc vllm-service -n llm-workshop
kubectl describe svc vllm-service -n llm-workshop
```{{exec}}

## Create Port Forward

Let's create a port forward to access vLLM from our local machine:

```bash
# Start port forward in the background
kubectl port-forward svc/vllm-service 8000:8000 -n llm-workshop &
sleep 2

# Verify port forward is running
ps aux | grep "kubectl port-forward" | grep -v grep
```{{exec}}

## Test Direct Access

Now let's test accessing vLLM directly via the port forward using the OpenAI-compatible API:

```bash
# Test vLLM health endpoint
curl http://localhost:8000/health

# Test models endpoint
curl http://localhost:8000/v1/models | python3 -m json.tool || curl http://localhost:8000/v1/models

# Test with a simple prompt using OpenAI-compatible API
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "What is Kubernetes?",
    "max_tokens": 100,
    "temperature": 0.7
  }' | python3 -m json.tool || curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "facebook/opt-125m",
    "prompt": "What is Kubernetes?",
    "max_tokens": 100,
    "temperature": 0.7
  }'
```{{exec}}

## Alternative: Use NodePort (Optional)

If you want to expose the service using NodePort instead, you can update the service:

```bash
# Update service to NodePort type
kubectl patch svc vllm-service -n llm-workshop -p '{"spec":{"type":"NodePort"}}'

# Get the NodePort
kubectl get svc vllm-service -n llm-workshop -o jsonpath='{.spec.ports[0].nodePort}'
echo

# Get node IP
kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'
echo
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

Let's create a script to easily interact with vLLM via the OpenAI-compatible API:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/ask-vllm.sh
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 'Your question here'"
    exit 1
fi

QUESTION="$1"

echo "🤖 Asking vLLM: $QUESTION"
echo "=========================="
echo

curl -s http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"facebook/opt-125m\",
    \"prompt\": \"$QUESTION\",
    \"max_tokens\": 150,
    \"temperature\": 0.7
  }" | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['text'])" 2>/dev/null || \
curl -s http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"facebook/opt-125m\",
    \"prompt\": \"$QUESTION\",
    \"max_tokens\": 150,
    \"temperature\": 0.7
  }"

echo
EOF

chmod +x /root/workspace/llm-workshop/ask-vllm.sh
```{{exec}}

## Test the Helper Script

```bash
# Test the helper script
/root/workspace/llm-workshop/ask-vllm.sh "What is container orchestration?"
```{{exec}}

## Verify Service Accessibility

Let's verify everything is working:

```bash
# Check if port forward is still running
pgrep -f "kubectl port-forward.*vllm-service"

# Test connectivity
curl -s http://localhost:8000/health
curl -s http://localhost:8000/v1/models | python3 -m json.tool 2>/dev/null || curl -s http://localhost:8000/v1/models
```{{exec}}

## Service Exposure Summary

We've successfully:
- ✅ Created port forwarding to access vLLM
- ✅ Tested direct API access using OpenAI-compatible endpoints
- ✅ Created helper scripts for easier interaction
- ✅ Verified the service is accessible

## Understanding Kubernetes Services

**Services** in Kubernetes provide:
- **Stable IP address** - Even when pods restart
- **Load balancing** - Distribute traffic across pod replicas
- **Service discovery** - Find services by name
- **Abstraction** - Hide pod details from consumers

Our `vllm-service`:
- Type: ClusterIP (internal access)
- Port: 8000 (vLLM's default port)
- Selector: `app=vllm-server` (routes to our vLLM pods)
- API: OpenAI-compatible REST API

## What's Next?

In the next step, we'll interact with the model by asking various questions and exploring its capabilities!

---

**Service exposed?** Let's ask some questions! 🚀
