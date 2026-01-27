# Step 3: Deploy a Service

In this step, we'll create a Service to provide stable network access to our Pods. Services abstract Pod IP addresses and provide load balancing across Pod replicas.

## Understanding Services

A Service provides:
- **Stable IP Address** - Service IP doesn't change even if Pods are recreated
- **Load Balancing** - Distributes traffic across Pod replicas
- **Service Discovery** - Other Pods can find services by name
- **Abstraction** - Hides Pod IP addresses which can change

## Types of Services

Kubernetes supports several Service types:
- **ClusterIP** (default) - Exposes service only within the cluster
- **NodePort** - Exposes service on each node's IP at a static port
- **LoadBalancer** - Exposes service externally using cloud provider's load balancer
- **ExternalName** - Maps service to an external DNS name

In this step, we'll create a ClusterIP service (the default type).

## Check Current Pods

Let's see the Pods we have from our Deployment:

```bash
kubectl get pods -n k8s-primer -l app=nginx-deployment
```{{exec}}

Notice that each Pod has its own IP address. These IPs can change when Pods are recreated.

## Create a Service

Let's create a Service that exposes our nginx Deployment:

```bash
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --name=nginx-service -n k8s-primer
```{{exec}}

## Verify Service Status

Check the Service:

```bash
kubectl get service nginx-service -n k8s-primer
```{{exec}}

Notice the Service has:
- A **ClusterIP** (internal IP address)
- A **Port** (80)
- **Endpoints** (the Pod IPs it routes to)

## View Service Details

Get detailed information about the Service:

```bash
kubectl describe service nginx-service -n k8s-primer
```{{exec}}

## Check Service Endpoints

The Service automatically discovers Pods using labels. Let's see which Pods the Service is routing to:

```bash
kubectl get endpoints nginx-service -n k8s-primer
```{{exec}}

## Test Service Access from Within Cluster

Let's test accessing the Service from within the cluster. We'll create a temporary Pod and curl the service:

```bash
kubectl run test-pod --image=curlimages/curl:latest --rm -it --restart=Never -- curl http://nginx-service.k8s-primer.svc.cluster.local
```{{exec}}

Alternatively, you can use the shorter service name (Kubernetes DNS resolves it):

```bash
kubectl run test-pod2 --image=curlimages/curl:latest --rm -it --restart=Never -n k8s-primer -- curl http://nginx-service
```{{exec}}

## Understand Service DNS

Services are accessible via DNS in the format:
- `http://<service-name>.<namespace>.svc.cluster.local`
- Or simply `http://<service-name>` (within the same namespace)

## View Service Labels and Selectors

Services use label selectors to find Pods. Let's see the selector:

```bash
kubectl get service nginx-service -n k8s-primer -o yaml | grep -A 2 selector
```{{exec}}

## Key Takeaways

- ✅ Services provide stable network access to Pods
- ✅ Services load balance traffic across Pod replicas
- ✅ Services use DNS for service discovery
- ✅ ClusterIP services are only accessible within the cluster
- ✅ Services automatically discover Pods using label selectors
- ✅ Use `kubectl get service` to view Services
- ✅ Use `kubectl get endpoints` to see which Pods a Service routes to

## What's Next?

In the next step, we'll create a NodePort Service to expose our application externally!

---

**Service created?** Let's create a NodePort Service! 🚀
