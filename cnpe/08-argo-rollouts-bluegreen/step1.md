# Create the blue/green Rollout

Look around first:

```plain
kubectl -n shop-core get deploy,svc,pods
```{{exec}}

Write the Rollout with a `strategy.blueGreen` block. The manual gate is a single
boolean - find it.

<details><summary>✦ Tip</summary>

```plain
kubectl explain rollout.spec.strategy.blueGreen --recursive | head -25
```{{copy}}

(Works because Rollouts installs its CRDs - `kubectl explain` reads them.)
The field you want is `autoPromotionEnabled: false`.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: catalog
  namespace: shop-core
spec:
  replicas: 2
  selector:
    matchLabels:
      app: catalog
  strategy:
    blueGreen:
      activeService: catalog-active
      previewService: catalog-preview
      autoPromotionEnabled: false
  template:
    metadata:
      labels:
        app: catalog
    spec:
      containers:
        - name: catalog
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF
```{{exec}}

```plain
kubectl argo rollouts get rollout catalog -n shop-core
```{{exec}}

Wait for `Status: ✔ Healthy`. Both services now point at the blue ReplicaSet
(Argo Rollouts injected a `rollouts-pod-template-hash` selector into them).

</details>
