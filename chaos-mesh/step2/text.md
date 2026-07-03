# Step 2: Chaos as Kubernetes Objects - Kill Pods with PodChaos

Your first Chaos Mesh experiment: a **PodChaos** resource that kills one nginx pod. No CLI, no scripts - just a Kubernetes object.

## Take a "Before" Snapshot

```bash
kubectl get pods -n demo -l app=nginx
kubectl get pods -n demo -l app=nginx -o name > /tmp/pods-before.txt
```{{exec}}

## Declare the Failure

Read the spec like a sentence: *kill (`action: pod-kill`) one pod (`mode: one`) matching `app=nginx` in the `demo` namespace*:

```bash
cat <<'EOF' > /root/pod-kill.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: kill-one-nginx
  namespace: demo
spec:
  action: pod-kill
  mode: one
  selector:
    namespaces:
      - demo
    labelSelectors:
      app: nginx
EOF
kubectl apply -f /root/pod-kill.yaml
```{{exec}}

That `kubectl apply` **is** the chaos injection. The controller-manager saw the new PodChaos object and told the chaos-daemon on the right node to kill the selected pod - immediately.

## Watch Kubernetes Heal

```bash
kubectl get pods -n demo -l app=nginx
echo "--- pods before the chaos ---"
cat /tmp/pods-before.txt
```{{exec}}

One pod has a **new name and a young age**: the ReplicaSet replaced the killed pod within seconds. Injection → recovery, the core chaos engineering loop.

## Inspect the Experiment Like Any Kubernetes Object

Because the experiment is a CRD, everything you know about Kubernetes objects applies:

```bash
kubectl get podchaos -n demo
kubectl describe podchaos kill-one-nginx -n demo | tail -20
```{{exec}}

Look at the `Records` and `Events` sections: Chaos Mesh tracks exactly **which pod** it selected and when the fault was injected. This audit trail is what makes CRD-based chaos GitOps-friendly - your chaos experiments can live in the same repo and pipeline as your deployments.

## One-Shot vs Recurring

`pod-kill` is instantaneous, so this experiment fired once and is done. Other actions (like `pod-failure` or network faults) take a `duration` and auto-revert when it expires - you'll see that next. For recurring chaos (e.g. "kill a random pod every 5 minutes"), Chaos Mesh has a `Schedule` resource that wraps any experiment in a cron.

Clean up the finished experiment:

```bash
kubectl delete podchaos kill-one-nginx -n demo
```{{exec}}
