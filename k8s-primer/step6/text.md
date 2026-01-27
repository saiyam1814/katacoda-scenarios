# Step 6: Resource Management - Requests and Limits

In this step, we'll learn about **resource management** in Kubernetes - how to control CPU and memory usage for your containers. This is crucial for production deployments and preventing resource starvation.

## Understanding Resource Management

Kubernetes allows you to specify:
- **Resource Requests** - Minimum resources guaranteed to a container
- **Resource Limits** - Maximum resources a container can use

## Why Resource Management Matters

Without proper resource management:
- ❌ Containers can consume all available resources
- ❌ One misbehaving Pod can starve others
- ❌ No guarantees about performance
- ❌ Difficult to plan capacity

With proper resource management:
- ✅ Predictable performance
- ✅ Better resource utilization
- ✅ Protection against resource exhaustion
- ✅ Enables scheduling decisions
- ✅ Enables autoscaling

## Understanding CPU and Memory Units

### CPU Units
- **1 CPU** = 1 vCPU/core = 1000m (millicores)
- **500m** = 0.5 CPU = half a core
- **250m** = 0.25 CPU = quarter of a core
- **100m** = 0.1 CPU

### Memory Units
- **Ki** = Kibibyte (1024 bytes)
- **Mi** = Mebibyte (1024 KiB)
- **Gi** = Gibibyte (1024 MiB)
- **Ti** = Tebibyte (1024 GiB)
- Examples: `128Mi`, `2Gi`, `500Mi`

## Resource Requests

**Requests** specify the minimum resources a container needs:
- Kubernetes **guarantees** these resources
- Used for **scheduling decisions** (Pod placement)
- If not available, Pod won't be scheduled
- Can be shared when not in use

## Resource Limits

**Limits** specify the maximum resources a container can use:
- Container **cannot exceed** these limits
- CPU: throttled if exceeded
- Memory: container killed (OOMKilled) if exceeded
- Prevents resource starvation

## Check Current Resource Usage

Let's first see what resources are available in our cluster:

```bash
kubectl describe nodes | grep -A 5 "Allocated resources"
```{{exec}}

Or get a summary:

```bash
kubectl top nodes 2>/dev/null || echo "Metrics server not available (this is OK for learning)"
```{{exec}}

## Create a Deployment with Resource Requests

Let's create a Deployment with resource requests and limits:

```bash
cat <<EOF > /root/workspace/k8s-primer/manifests/resource-demo.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-demo
  namespace: k8s-primer
  labels:
    app: resource-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: resource-demo
  template:
    metadata:
      labels:
        app: resource-demo
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
EOF
```{{exec}}

## Understanding the Resource Configuration

In our manifest:
- **requests.memory: "64Mi"** - Guaranteed 64 MiB of memory
- **requests.cpu: "100m"** - Guaranteed 0.1 CPU (100 millicores)
- **limits.memory: "128Mi"** - Maximum 128 MiB of memory
- **limits.cpu: "200m"** - Maximum 0.2 CPU (200 millicores)

## Apply the Deployment

```bash
kubectl apply -f /root/workspace/k8s-primer/manifests/resource-demo.yaml
```{{exec}}

Wait for the Pod to be ready:

```bash
kubectl wait --for=condition=ready pod -l app=resource-demo -n k8s-primer --timeout=60s
```{{exec}}

## Verify Resource Configuration

Check the resource configuration:

```bash
kubectl describe pod -l app=resource-demo -n k8s-primer | grep -A 10 "Limits\|Requests"
```{{exec}}

Or get it in YAML format:

```bash
kubectl get pod -l app=resource-demo -n k8s-primer -o yaml | grep -A 8 resources
```{{exec}}

## View Resource Usage

If metrics server is available, view actual usage:

```bash
kubectl top pod -l app=resource-demo -n k8s-primer 2>/dev/null || echo "Metrics not available"
```{{exec}}

## Understanding CPU Throttling

When a container exceeds its CPU limit:
- CPU usage is **throttled** (slowed down)
- Container continues running
- Performance degrades but doesn't crash

## Understanding Memory Limits

When a container exceeds its memory limit:
- Container is **terminated** (OOMKilled)
- Pod status shows `OOMKilled`
- Kubernetes may restart the Pod (depending on restart policy)

## Create a Pod with Insufficient Resources

Let's see what happens when we request more resources than available. First, check node capacity:

```bash
kubectl describe nodes | grep -E "Capacity|Allocatable" | head -4
```{{exec}}

Now, let's try to create a Pod that requests too much memory:

```bash
cat <<EOF > /root/workspace/k8s-primer/manifests/too-much-memory.yaml
apiVersion: v1
kind: Pod
metadata:
  name: too-much-memory
  namespace: k8s-primer
spec:
  containers:
  - name: test
    image: nginx:1.21
    resources:
      requests:
        memory: "1000Gi"  # Way too much!
        cpu: "1000"       # Way too much!
EOF
```{{exec}}

Try to create it:

```bash
kubectl apply -f /root/workspace/k8s-primer/manifests/too-much-memory.yaml
```{{exec}}

Check the Pod status - it should be Pending:

```bash
kubectl get pod too-much-memory -n k8s-primer
kubectl describe pod too-much-memory -n k8s-primer | grep -A 5 "Events"
```{{exec}}

You'll see it can't be scheduled due to insufficient resources. Let's clean it up:

```bash
kubectl delete pod too-much-memory -n k8s-primer
```{{exec}}

## Best Practices for Resource Management

### 1. **Set Both Requests and Limits**
- Requests for scheduling
- Limits for protection

### 2. **Start Conservative**
- Begin with reasonable estimates
- Monitor and adjust based on actual usage

### 3. **Use Monitoring**
- Track actual resource usage
- Adjust based on metrics

### 4. **Consider Workload Types**
- **CPU-intensive**: Higher CPU limits
- **Memory-intensive**: Higher memory limits
- **I/O-intensive**: May need different considerations

### 5. **Test Resource Limits**
- Verify applications work within limits
- Test what happens when limits are hit

## Resource Quotas and Namespaces

In production, you might also use:
- **ResourceQuotas** - Limit total resources per namespace
- **LimitRanges** - Set default requests/limits for a namespace

## Update Resources

You can update resource requests and limits by editing the manifest and reapplying:

```bash
# Edit the file
sed -i 's/memory: "64Mi"/memory: "128Mi"/' /root/workspace/k8s-primer/manifests/resource-demo.yaml
sed -i 's/memory: "128Mi"/memory: "256Mi"/' /root/workspace/k8s-primer/manifests/resource-demo.yaml

# Apply the changes
kubectl apply -f /root/workspace/k8s-primer/manifests/resource-demo.yaml
```{{exec}}

The Deployment will perform a rolling update with the new resources.

## Key Takeaways

- ✅ **Requests** = minimum guaranteed resources (for scheduling)
- ✅ **Limits** = maximum allowed resources (for protection)
- ✅ CPU measured in millicores (m) or whole CPUs
- ✅ Memory measured in Mi, Gi, etc. (binary units)
- ✅ Exceeding CPU limit = throttling
- ✅ Exceeding memory limit = container killed (OOMKilled)
- ✅ Resources are crucial for production deployments
- ✅ Use monitoring to set appropriate values

## What's Next?

In the next step, we'll learn about port forwarding and kubectl exec - essential tools for debugging and accessing your applications!

---

**Resources configured?** Let's learn about port forwarding! 🚀
