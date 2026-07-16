# Create the Rollout

Inspect what exists — the names in the cluster are your source of truth:

```plain
kubectl -n release-bay get deploy,svc,virtualservice
```{{exec}}

A `Rollout` is a drop-in Deployment replacement (`argoproj.io/v1alpha1`) with a
`strategy.canary` block. Wire in the two services, the Istio VirtualService/route,
and the weight steps.

<details><summary>✦ Tip 1 — the strategy block shape</summary>

```yaml
strategy:
  canary:
    canaryService: <svc>
    stableService: <svc>
    trafficRouting:
      istio:
        virtualService:
          name: <vs-name>
          routes: [<route-name>]
    steps:
      - setWeight: 20
      - pause: { duration: 30s }
```{{copy}}

</details>

<details><summary>✦ Tip 2 — about the old Deployment</summary>

The task says don't *edit* it. A Rollout with its own template simply takes over the
services (Argo Rollouts adds a pod-template-hash selector to them). Scaling the old
Deployment down afterwards is good hygiene — the book chapter also shows the
`workloadRef` migration pattern, which adopts an existing Deployment instead.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: media-proxy
  namespace: release-bay
spec:
  replicas: 3
  selector:
    matchLabels:
      app: media-proxy
  strategy:
    canary:
      canaryService: media-proxy-canary
      stableService: media-proxy-stable
      trafficRouting:
        istio:
          virtualService:
            name: media-proxy
            routes: [primary]
      steps:
        - setWeight: 20
        - pause: { duration: 30s }
        - setWeight: 40
        - pause: { duration: 30s }
        - setWeight: 100
  template:
    metadata:
      labels:
        app: media-proxy
    spec:
      containers:
        - name: media-proxy
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF
```{{exec}}

Check it becomes Healthy (first revision skips the steps — nothing to canary against yet):

```plain
kubectl argo rollouts get rollout media-proxy -n release-bay
```{{exec}}

</details>
