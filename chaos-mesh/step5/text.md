# Step 5: Chain Experiments into a Chaos Workflow

Real incidents are compound: pods die *while* the network degrades. Chaos Mesh **Workflows** compose experiments into serial and parallel graphs - like a CI pipeline, but for failures.

## Declare a Two-Stage Chaos Campaign

This Workflow runs serially: first kill an nginx pod, then inject 100ms latency for 30 seconds. Each task embeds a full chaos spec you already know:

```bash
cat <<'EOF' > /root/chaos-workflow.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: Workflow
metadata:
  name: chaos-campaign
  namespace: demo
spec:
  entry: serial-entry
  templates:
    - name: serial-entry
      templateType: Serial
      deadline: 300s
      children:
        - kill-a-pod
        - slow-the-network
    - name: kill-a-pod
      templateType: PodChaos
      deadline: 30s
      podChaos:
        action: pod-kill
        mode: one
        selector:
          namespaces:
            - demo
          labelSelectors:
            app: nginx
    - name: slow-the-network
      templateType: NetworkChaos
      deadline: 30s
      networkChaos:
        action: delay
        mode: all
        selector:
          namespaces:
            - demo
          labelSelectors:
            app: nginx
        delay:
          latency: '100ms'
EOF
kubectl apply -f /root/chaos-workflow.yaml
```{{exec}}

## Watch the Campaign Execute

The workflow spawns each chaos experiment in order. Watch the nodes appear:

```bash
kubectl get workflownodes -n demo
kubectl get podchaos,networkchaos -n demo
```{{exec}}

Re-run that a few times over the next minute: `kill-a-pod` completes first, *then* `slow-the-network` starts (you can feel it with a curl through the client pod while it's active). Check the overall status:

```bash
kubectl describe workflow chaos-campaign -n demo | tail -15
```{{exec}}

The dashboard's **Workflows** page shows this same campaign as a visual graph with live status per node - take a look in the tab you opened in Step 4.

## Confirm the Cluster Survived

After the workflow finishes (~1 minute):

```bash
kubectl exec client -n demo -- curl -o /dev/null -s -w "latency after campaign: %{time_total}s\n" http://nginx.demo
kubectl get pods -n demo -l app=nginx
```{{exec}}

Fast responses and 3/3 replicas: your cluster survived a multi-stage chaos campaign, defined entirely in one YAML file you could commit to git and run on every release.

> **Beyond Serial**: Workflows also support `Parallel` templates (compound failures at once), `Suspend` (wait between stages), `StatusCheck` (abort the campaign if your app's health endpoint fails - automated blast-radius control), and `Task` (run custom containers to validate SLOs mid-campaign).
