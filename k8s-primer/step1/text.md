# Step 1: Deploy a Pod

In this step, we'll deploy your first Pod in Kubernetes. A Pod is the smallest deployable unit in Kubernetes and can contain one or more containers.

## Understanding Pods

A Pod is a group of one or more containers that share:
- **Storage** - Volumes are shared between containers
- **Network** - Containers share the same IP and port space
- **Lifecycle** - Containers start and stop together

## Check Cluster Status

First, let's verify our Kubernetes cluster is running:

```bash
kubectl get nodes
kubectl cluster-info
```{{exec}}

## Create a Namespace

Let's create a dedicated namespace for our primer:

```bash
kubectl create namespace k8s-primer
kubectl config set-context --current --namespace=k8s-primer
```{{exec}}

## Deploy Your First Pod

We'll create a simple Pod running nginx. You can create a Pod using `kubectl run`:

```bash
kubectl run nginx-pod --image=nginx:1.21 --namespace=k8s-primer
```{{exec}}

## Verify Pod Status

Let's check if the Pod is running:

```bash
kubectl get pods -n k8s-primer
```{{exec}}

Wait a few seconds and check again to see the Pod status change from `ContainerCreating` to `Running`:

```bash
sleep 5
kubectl get pods -n k8s-primer
```{{exec}}

## Get Detailed Pod Information

View detailed information about your Pod:

```bash
kubectl describe pod nginx-pod -n k8s-primer
```{{exec}}

## View Pod Logs

Check the logs from your Pod:

```bash
kubectl logs nginx-pod -n k8s-primer
```{{exec}}

## Understanding Pod Lifecycle

Pods go through several phases:
- **Pending** - Pod is being scheduled
- **Running** - Pod is bound to a node and containers are running
- **Succeeded** - All containers terminated successfully
- **Failed** - At least one container terminated in failure
- **Unknown** - Pod state cannot be determined

## Key Takeaways

- ✅ Pods are the basic unit of deployment in Kubernetes
- ✅ Each Pod gets its own IP address
- ✅ Pods are ephemeral - they can be created and destroyed
- ✅ Use `kubectl get pods` to view Pod status
- ✅ Use `kubectl describe pod` for detailed information
- ✅ Use `kubectl logs` to view container logs

## What's Next?

In the next step, we'll learn about Deployments, which provide a better way to manage Pods with features like replication, rolling updates, and self-healing!

---

**Pod deployed?** Let's move to Deployments! 🚀
