# Deploy vLLM with CPU Mode and Verify Operation

Now let's deploy vLLM with CPU mode on our Kubernetes cluster. vLLM is a high-performance LLM inference engine that supports CPU-only inference, which is perfect for our environment. Note that llm-d uses vLLM under the hood for CPU inference.

## Understanding vLLM CPU Mode

vLLM is a high-performance LLM inference and serving engine that:
- **CPU Support**: Has a dedicated CPU backend for CPU-only inference
- **High Performance**: Optimized inference engine with efficient memory management
- **OpenAI-Compatible API**: Provides OpenAI-compatible REST API
- **Production Ready**: Used by llm-d and other production systems
- **Flexible**: Supports various model sizes and data types (FP32, FP16, BF16)

**Note**: llm-d is a Kubernetes-native framework built on top of vLLM. For this workshop, we'll use vLLM directly with CPU mode, which is what llm-d uses under the hood.

**Important**: The official `vllm/vllm-cpu` image doesn't exist on Docker Hub. We use the community-maintained `ghcr.io/stackhpc/vllm-cpu` image from StackHPC, which provides a working vLLM CPU build.

## Deploy vLLM with CPU Mode

Let's create the vLLM deployment manifest with CPU mode:

```bash
# Create the vLLM deployment manifest with CPU mode
cat <<EOF > /root/workspace/llm-workshop/vllm-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-server
  namespace: llm-workshop
  labels:
    app: vllm-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm-server
  template:
    metadata:
      labels:
        app: vllm-server
    spec:
      containers:
      - name: vllm-server
        # Using StackHPC's vLLM CPU image (official vllm/vllm-cpu doesn't exist)
        image: ghcr.io/stackhpc/vllm-cpu:v0.10.2
        ports:
        - containerPort: 8000
        env:
        - name: VLLM_CPU_KVCACHE_SPACE
          value: "2"
        - name: VLLM_CPU_OMP_THREADS_BIND
          value: "auto"
        command: ["python", "-m", "vllm.entrypoints.openai.api_server"]
        args: [
          "--model", "facebook/opt-125m",
          "--dtype", "float32",
          "--host", "0.0.0.0",
          "--port", "8000",
          "--max-num-seqs", "8",
          "--max-model-len", "512"
        ]
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 120
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 60
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: vllm-service
  namespace: llm-workshop
spec:
  selector:
    app: vllm-server
  ports:
  - port: 8000
    targetPort: 8000
  type: ClusterIP
EOF

# Deploy vLLM
kubectl apply -f /root/workspace/llm-workshop/vllm-deployment.yaml
```{{exec}}

## Wait for Deployment

Let's wait for the vLLM pod to be ready (this may take a few minutes as it downloads the model):

```bash
kubectl wait --for=condition=ready pod -l app=vllm-server -n llm-workshop --timeout=600s
```{{exec}}

## Verify vLLM is Running

Check that vLLM is running correctly:

```bash
kubectl get pods -n llm-workshop
kubectl get svc -n llm-workshop
```{{exec}}

## Verify CPU Operation

Let's verify that vLLM is running on CPU (not GPU):

```bash
# Check the pod details to see it's using CPU
kubectl describe pod -l app=vllm-server -n llm-workshop | grep -A 5 "Limits\|Requests"

# Check if the pod is actually running (not waiting for GPU)
kubectl get pods -n llm-workshop -o wide

# Check pod logs to verify CPU mode
kubectl logs -l app=vllm-server -n llm-workshop --tail=20 | grep -i cpu || echo "Checking logs..."

# Verify CPU usage
kubectl top pod -l app=vllm-server -n llm-workshop 2>/dev/null || echo "Metrics server not available"
```{{exec}}

## Test vLLM API

Let's test that vLLM is responding:

```bash
# Check health endpoint
curl -s http://$(kubectl get svc vllm-service -n llm-workshop -o jsonpath='{.spec.clusterIP}'):8000/health || echo "Waiting for service..."

# List available models
curl -s http://$(kubectl get svc vllm-service -n llm-workshop -o jsonpath='{.spec.clusterIP}'):8000/v1/models || echo "Service may still be starting..."
```{{exec}}

## Understanding vLLM CPU Mode vs GPU

**vLLM CPU Mode**:
- Uses CPU for inference (no GPU required)
- Optimized for CPU with efficient memory management
- Supports FP32, FP16, and BF16 data types
- Good for smaller models and learning environments
- Lower resource requirements than full llm-d deployment

**vLLM GPU Mode**:
- Uses GPU for faster inference
- Better for large models and production workloads
- Requires GPU drivers and hardware

**llm-d Framework**:
- Built on top of vLLM
- Adds Kubernetes-native features (scheduling, load balancing)
- Production-ready with advanced features
- Requires 64+ cores and 64GB+ RAM per replica for CPU mode

For this workshop, we're using **vLLM CPU mode directly**, which:
- Uses the same engine that llm-d uses
- Works with our resource constraints
- Perfect for learning and experimentation
- Demonstrates CPU-based LLM inference

## vLLM Deployment Summary

We've successfully:
- ✅ Deployed vLLM with CPU mode on Kubernetes
- ✅ Created a service to expose vLLM internally
- ✅ Verified vLLM is running on CPU (not GPU)
- ✅ Confirmed the pod is ready and healthy
- ✅ Tested the API endpoints

## What's Next?

In the next step, we'll test the model and verify it's working correctly!

---

**vLLM running on CPU?** Let's test the model! 🚀
