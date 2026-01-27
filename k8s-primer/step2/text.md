# Step 2: Deploy a Deployment

In this step, we'll create a Deployment, which is a higher-level abstraction that manages Pod replicas. Deployments provide features like replication, rolling updates, and self-healing.

## Understanding Deployments

A Deployment provides:
- **Replication** - Maintains a desired number of Pod replicas
- **Rolling Updates** - Updates Pods gradually without downtime
- **Rollbacks** - Revert to previous versions if needed
- **Self-Healing** - Automatically replaces failed Pods

## Clean Up Previous Pod

First, let's remove the Pod we created in Step 1 (Deployments will create Pods for us):

```bash
kubectl delete pod nginx-pod -n k8s-primer
```{{exec}}

## Create a Deployment

Let's create a Deployment that manages 3 replicas of nginx:

```bash
kubectl create deployment nginx-deployment --image=nginx:1.21 --replicas=3 -n k8s-primer
```{{exec}}

## Verify Deployment Status

Check the Deployment status:

```bash
kubectl get deployment nginx-deployment -n k8s-primer
```{{exec}}

## View Pods Created by Deployment

The Deployment automatically created Pods. Let's see them:

```bash
kubectl get pods -n k8s-primer -l app=nginx-deployment
```{{exec}}

Notice that the Deployment created 3 Pods (replicas). Wait a moment for them to be ready:

```bash
sleep 5
kubectl get pods -n k8s-primer -l app=nginx-deployment
```{{exec}}

## Get Detailed Deployment Information

View detailed information about your Deployment:

```bash
kubectl describe deployment nginx-deployment -n k8s-primer
```{{exec}}

## Scale the Deployment

One of the powerful features of Deployments is easy scaling. Let's scale up to 5 replicas:

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n k8s-primer
```{{exec}}

Verify the new Pods are being created:

```bash
kubectl get pods -n k8s-primer -l app=nginx-deployment
```{{exec}}

## Scale Down

Let's scale back down to 3 replicas:

```bash
kubectl scale deployment nginx-deployment --replicas=3 -n k8s-primer
```{{exec}}

```bash
kubectl get pods -n k8s-primer -l app=nginx-deployment
```{{exec}}

## Test Self-Healing

Deployments automatically replace failed Pods. Let's simulate a Pod failure:

```bash
kubectl delete pod -l app=nginx-deployment -n k8s-primer --field-selector=status.phase=Running
```{{exec}}

Wait a moment and check - the Deployment should have created a new Pod:

```bash
sleep 3
kubectl get pods -n k8s-primer -l app=nginx-deployment
```{{exec}}

## Key Takeaways

- ✅ Deployments manage Pod replicas automatically
- ✅ Deployments provide self-healing capabilities
- ✅ Easy to scale Deployments up or down
- ✅ Deployments use labels to manage Pods
- ✅ Use `kubectl get deployment` to view Deployment status
- ✅ Use `kubectl scale` to change replica count

## What's Next?

In the next step, we'll learn about Services, which provide stable network access to our Pods!

---

**Deployment created?** Let's create a Service! 🚀
