# Step 3: Inject Network Latency and Measure It

Killing pods tests your controllers. But the failures that actually hurt in production are usually *degradations*: a slow dependency, a laggy network link. **NetworkChaos** simulates those with surgical precision using the kernel's traffic control (`tc netem`).

## Measure the Baseline

From the client pod, time 5 requests to the nginx Service:

```bash
for i in 1 2 3 4 5; do
  kubectl exec client -n demo -- curl -o /dev/null -s -w "request $i: %{time_total}s\n" http://nginx.demo
done
```{{exec}}

A few **milliseconds** per request - pod-to-pod networking is fast.

## Declare 200ms of Latency

Now inject 200ms (±20ms jitter) of delay on **all** nginx pods for **2 minutes**:

```bash
cat <<'EOF' > /root/network-delay.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: nginx-delay
  namespace: demo
spec:
  action: delay
  mode: all
  selector:
    namespaces:
      - demo
    labelSelectors:
      app: nginx
  delay:
    latency: '200ms'
    jitter: '20ms'
  duration: '2m'
EOF
kubectl apply -f /root/network-delay.yaml
```{{exec}}

Note the `duration: '2m'` - unlike the instant pod-kill, this fault **persists and then auto-reverts**. Behind the scenes, the chaos-daemon on each node just added a `tc netem` rule inside the nginx pods' network namespaces.

## Measure Again - Feel the Pain

```bash
for i in 1 2 3 4 5; do
  kubectl exec client -n demo -- curl -o /dev/null -s -w "request $i: %{time_total}s\n" http://nginx.demo
done
```{{exec}}

Requests now take **hundreds of milliseconds** - your "fast" service just became a slow dependency. This is the moment to ask the production questions: do your timeouts fire? Do retries make it worse? Does your dashboard even notice?

Check the experiment status while it's active:

```bash
kubectl get networkchaos -n demo
kubectl describe networkchaos nginx-delay -n demo | grep -A 10 "Events"
```{{exec}}

## Revert Instantly

You could wait out the 2 minutes, but there's a faster way - deleting the resource reverts the fault immediately:

```bash
kubectl delete networkchaos nginx-delay -n demo
for i in 1 2 3; do
  kubectl exec client -n demo -- curl -o /dev/null -s -w "request $i: %{time_total}s\n" http://nginx.demo
done
```{{exec}}

Milliseconds again. **Declarative chaos means declarative rollback**: the fault exists exactly as long as the Kubernetes object does. No leftover `tc` rules, no cleanup scripts.

> NetworkChaos can also simulate packet **loss**, **corruption**, **duplication**, **reordering**, **bandwidth limits**, and full **partitions** between pod groups - all with the same selector + duration pattern you just used.
