# Scaling and Optimization

Now let's explore scaling and optimization strategies for our LLM workloads on Kubernetes.

## Understanding Scaling Strategies

Kubernetes provides several ways to scale LLM workloads:

### 📈 **Horizontal Pod Autoscaler (HPA)**
- Automatically scales pods based on CPU/memory usage
- Perfect for stateless LLM services
- Can scale based on custom metrics

### 🔄 **Vertical Pod Autoscaler (VPA)**
- Adjusts resource requests/limits automatically
- Right-sizes containers based on usage
- Reduces resource waste

### 🏗️ **Cluster Autoscaler**
- Adds/removes nodes based on demand
- Cost optimization
- Multi-zone scaling

## Deploy HPA

Let's create and deploy the Horizontal Pod Autoscaler:

```bash
# Create the HPA manifest
cat <<EOF > /home/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: vllm-hpa
  namespace: llm-workshop
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vllm-server
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: rag-app-hpa
  namespace: llm-workshop
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: rag-app
  minReplicas: 1
  maxReplicas: 2
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
EOF

# Deploy HPA
kubectl apply -f /home/hpa.yaml
```{{exec}}

## Create Additional HPA for vLLM

Let's also create a custom HPA for our vLLM service:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: vllm-hpa
  namespace: llm-workshop
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vllm-server
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF
```

## Monitor Scaling

Let's check the HPA status:

```bash
kubectl get hpa -n llm-workshop
kubectl describe hpa vllm-hpa -n llm-workshop
```

## Create Load Testing Script

Let's create a simple load testing script to trigger scaling:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/load-test.sh
#!/bin/bash

echo "Starting load test for vLLM service..."
echo "This will send multiple requests to trigger HPA scaling"

# Function to send a request
send_request() {
    curl -s -X POST http://localhost:8000/v1/completions \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"facebook/opt-125m\",
            \"prompt\": \"Explain Kubernetes scaling in detail. This is a longer prompt to increase processing time.\",
            \"max_tokens\": 100
        }" > /dev/null
}

# Send multiple concurrent requests
for i in {1..10}; do
    send_request &
done

wait
echo "Load test completed!"
EOF

chmod +x /root/workspace/llm-workshop/load-test.sh
```

## Monitor Resource Usage

Let's monitor our resources during scaling:

```bash
# Watch pods scaling
kubectl get pods -n llm-workshop -w

# Check resource usage
kubectl top pods -n llm-workshop

# Check HPA events
kubectl get events -n llm-workshop --sort-by='.lastTimestamp'
```

## Create Monitoring Dashboard

Let's create a simple monitoring script:

```bash
cat <<'EOF' > /root/workspace/llm-workshop/monitor.sh
#!/bin/bash

echo "=== LLM Workshop Resource Monitoring ==="
echo "Timestamp: $(date)"
echo

echo "=== Pod Status ==="
kubectl get pods -n llm-workshop

echo
echo "=== Resource Usage ==="
kubectl top pods -n llm-workshop

echo
echo "=== HPA Status ==="
kubectl get hpa -n llm-workshop

echo
echo "=== Service Endpoints ==="
kubectl get svc -n llm-workshop

echo
echo "=== Recent Events ==="
kubectl get events -n llm-workshop --sort-by='.lastTimestamp' | tail -5
EOF

chmod +x /root/workspace/llm-workshop/monitor.sh
```

## Test Scaling

Let's run our load test and monitor scaling:

```bash
# Run load test in background
/root/workspace/llm-workshop/load-test.sh &

# Monitor scaling
watch -n 2 /root/workspace/llm-workshop/monitor.sh
```

## Scaling Summary

We've successfully implemented:
- ✅ Horizontal Pod Autoscaler for automatic scaling
- ✅ Load testing to trigger scaling
- ✅ Resource monitoring and dashboards
- ✅ Production-ready configurations

## What's Next?

In the final step, we'll clean up our resources and discuss next steps for production deployment!

---

**Scaling working?** Let's wrap up and plan for production! 🚀
