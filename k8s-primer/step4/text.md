# Step 4: Deploy a NodePort Service

In this step, we'll create a NodePort Service to expose our application externally. NodePort Services map a port on each node to the service, allowing access from outside the cluster.

## Understanding NodePort Services

A NodePort Service:
- **Extends ClusterIP** - NodePort is built on top of ClusterIP
- **External Access** - Exposes service on each node's IP at a static port
- **Port Range** - Uses ports in the range 30000-32767 (by default)
- **Development/Testing** - Useful for exposing services during development

## Check Current Service

Let's see our existing ClusterIP service:

```bash
kubectl get service nginx-service -n k8s-primer
```{{exec}}

## Create a NodePort Service

We'll create a new NodePort service. First, let's delete the existing ClusterIP service and create a NodePort one:

```bash
kubectl delete service nginx-service -n k8s-primer
```{{exec}}

Now create a NodePort service:

```bash
kubectl expose deployment nginx-deployment --type=NodePort --port=80 --target-port=80 --name=nginx-nodeport -n k8s-primer
```{{exec}}

## Verify NodePort Service

Check the NodePort service:

```bash
kubectl get service nginx-nodeport -n k8s-primer
```{{exec}}

Notice the service now has:
- A **ClusterIP** (for internal access)
- A **NodePort** (the external port, typically 30000-32767)
- A **Port** (80, the service port)

## Get NodePort Number

Let's get the specific NodePort number:

```bash
kubectl get service nginx-nodeport -n k8s-primer -o jsonpath='{.spec.ports[0].nodePort}'
echo
```{{exec}}

## View Service Details

Get detailed information:

```bash
kubectl describe service nginx-nodeport -n k8s-primer
```{{exec}}

## Get Node IP Addresses

To access the service externally, we need a node IP. Let's get the node IPs:

```bash
kubectl get nodes -o wide
```{{exec}}

Or get just the IP addresses:

```bash
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
echo
```{{exec}}

## Test NodePort Access

Now you can access the service using:
- **NodeIP:NodePort** (e.g., `<node-ip>:<nodeport>`)

Let's test it from within the cluster using curl:

```bash
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODEPORT=$(kubectl get service nginx-nodeport -n k8s-primer -o jsonpath='{.spec.ports[0].nodePort}')
echo "Access the service at: http://$NODE_IP:$NODEPORT"
```{{exec}}

Test the access:

```bash
kubectl run test-nodeport --image=curlimages/curl:latest --rm -it --restart=Never -n k8s-primer -- curl -s http://$NODE_IP:$NODEPORT | head -20
```{{exec}}

## Understand Service Types Comparison

Let's compare the service types:

| Type | Access | Use Case |
|------|--------|----------|
| **ClusterIP** | Internal only | Default, internal services |
| **NodePort** | External via NodeIP:NodePort | Development, testing |
| **LoadBalancer** | External via cloud LB | Production (cloud environments) |

## View All Services

Let's see all services in our namespace:

```bash
kubectl get services -n k8s-primer
```{{exec}}

## Key Takeaways

- ✅ NodePort Services extend ClusterIP with external access
- ✅ NodePort uses ports 30000-32767 by default
- ✅ Access via `<NodeIP>:<NodePort>` from outside cluster
- ✅ Useful for development and testing
- ✅ Each node in the cluster can access the service
- ✅ Use `kubectl expose --type=NodePort` to create NodePort services
- ✅ NodePort services still work internally via ClusterIP

## Cleanup (Optional)

If you want to clean up, you can delete the service:

```bash
# kubectl delete service nginx-nodeport -n k8s-primer
```

## What's Next?

Congratulations! You've completed the Kubernetes Primer. You now understand:
- ✅ How to deploy Pods
- ✅ How to manage Pods with Deployments
- ✅ How to expose Pods internally with Services
- ✅ How to expose Pods externally with NodePort Services

You're now ready to move on to more advanced Kubernetes workshops!

---

**NodePort Service created?** You've completed the Kubernetes Primer! 🎉
