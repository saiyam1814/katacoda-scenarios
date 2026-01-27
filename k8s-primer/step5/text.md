# Step 5: Working with YAML Manifests

In this step, we'll learn about the **declarative approach** to Kubernetes using YAML manifests. This is the preferred method for production deployments and is essential for understanding how Kubernetes resources are defined.

## Understanding Declarative vs Imperative

Kubernetes supports two approaches to managing resources:

### **Imperative Approach** (What we've been using)
- Uses commands like `kubectl run`, `kubectl create`, `kubectl expose`
- Quick for learning and testing
- Hard to version control
- Difficult to reproduce exactly

### **Declarative Approach** (What we'll learn now)
- Uses YAML files to describe desired state
- Version controlled (Git-friendly)
- Reproducible and consistent
- Industry standard for production
- Can be applied with `kubectl apply`

## Why YAML Manifests Matter

**YAML (YAML Ain't Markup Language)** manifests are:
- **Human-readable** - Easy to understand and review
- **Version controlled** - Track changes in Git
- **Reusable** - Share and reuse configurations
- **Declarative** - Describe what you want, not how to do it
- **Idempotent** - Apply multiple times safely

## Understanding YAML Structure

Every Kubernetes resource has:
- **apiVersion** - API version to use
- **kind** - Type of resource (Pod, Deployment, Service, etc.)
- **metadata** - Name, labels, namespace
- **spec** - Desired state of the resource
- **status** - Current state (managed by Kubernetes)

## Create a Deployment Manifest

Let's create a YAML manifest for a Deployment. First, create a directory for our manifests:

```bash
mkdir -p /root/workspace/k8s-primer/manifests
cd /root/workspace/k8s-primer/manifests
```{{exec}}

Now, let's create a Deployment manifest:

```bash
cat <<EOF > webapp-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
  namespace: k8s-primer
  labels:
    app: webapp
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: http
EOF
```{{exec}}

## Understanding the Manifest Structure

Let's break down what we just created:

- **apiVersion: apps/v1** - Uses the apps API group, version 1
- **kind: Deployment** - This is a Deployment resource
- **metadata.name** - Unique name for this Deployment
- **metadata.namespace** - Where to create it
- **metadata.labels** - Key-value pairs for organization
- **spec.replicas** - Desired number of Pod replicas
- **spec.selector** - How to find Pods managed by this Deployment
- **spec.template** - Pod template (what Pods should look like)
- **spec.template.spec.containers** - Container definitions

## Apply the Manifest

Now let's apply this manifest to create the Deployment:

```bash
kubectl apply -f webapp-deployment.yaml
```{{exec}}

## Verify the Deployment

Check that the Deployment was created:

```bash
kubectl get deployment webapp-deployment -n k8s-primer
kubectl get pods -n k8s-primer -l app=webapp
```{{exec}}

## Create a Service Manifest

Now let's create a Service manifest to expose our Deployment:

```bash
cat <<EOF > webapp-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
  namespace: k8s-primer
  labels:
    app: webapp
spec:
  type: ClusterIP
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
EOF
```{{exec}}

## Understanding Service Manifest

Key parts of the Service manifest:
- **apiVersion: v1** - Services are in the core v1 API
- **spec.type: ClusterIP** - Internal service (default)
- **spec.selector** - Matches Pods with these labels
- **spec.ports** - Port mapping configuration

## Apply the Service

```bash
kubectl apply -f webapp-service.yaml
```{{exec}}

Verify the service:

```bash
kubectl get service webapp-service -n k8s-primer
```{{exec}}

## View the Applied Manifests

You can view the current state of your resources in YAML format:

```bash
kubectl get deployment webapp-deployment -n k8s-primer -o yaml
```{{exec}}

Or in a more readable format:

```bash
kubectl get deployment webapp-deployment -n k8s-primer -o yaml | head -30
```{{exec}}

## Update a Manifest

One of the benefits of YAML manifests is easy updates. Let's scale the Deployment by editing the manifest:

```bash
sed -i 's/replicas: 2/replicas: 4/' webapp-deployment.yaml
cat webapp-deployment.yaml | grep replicas
```{{exec}}

Apply the updated manifest:

```bash
kubectl apply -f webapp-deployment.yaml
```{{exec}}

Verify the change:

```bash
kubectl get pods -n k8s-primer -l app=webapp
```{{exec}}

## Apply Multiple Manifests

You can apply multiple manifests at once:

```bash
kubectl apply -f webapp-deployment.yaml -f webapp-service.yaml
```{{exec}}

Or apply all manifests in a directory:

```bash
kubectl apply -f /root/workspace/k8s-primer/manifests/
```{{exec}}

## Understanding kubectl apply

The `kubectl apply` command:
- **Creates** resources if they don't exist
- **Updates** resources if they already exist
- **Idempotent** - Safe to run multiple times
- **Three-way merge** - Compares desired state, current state, and last applied state

## Delete Resources from Manifest

You can delete resources using the manifest:

```bash
kubectl delete -f webapp-deployment.yaml
kubectl delete -f webapp-service.yaml
```{{exec}}

Or delete all resources in a directory:

```bash
# kubectl delete -f /root/workspace/k8s-primer/manifests/
```

## Best Practices for YAML Manifests

1. **Use meaningful names** - Clear, descriptive resource names
2. **Add labels** - Organize and select resources easily
3. **Version control** - Store manifests in Git
4. **Validate before applying** - Use `kubectl apply --dry-run=client -f file.yaml`
5. **Use namespaces** - Organize resources logically
6. **Document complex configs** - Add comments in YAML (use `#`)

## Validate Manifests

Before applying, you can validate your YAML:

```bash
kubectl apply --dry-run=client -f webapp-deployment.yaml
```{{exec}}

This shows what would happen without actually creating resources.

## Key Takeaways

- ✅ YAML manifests are the declarative way to manage Kubernetes
- ✅ Declarative approach is preferred for production
- ✅ Manifests are version-controlled and reproducible
- ✅ `kubectl apply` creates or updates resources
- ✅ Every resource has apiVersion, kind, metadata, and spec
- ✅ Labels and selectors connect resources together
- ✅ Use `--dry-run=client` to validate before applying
- ✅ Manifests can be applied multiple times safely (idempotent)

## What's Next?

In the next step, we'll learn about resource management - how to control CPU and memory usage for your containers!

---

**YAML manifests created?** Let's learn about resource management! 🚀
