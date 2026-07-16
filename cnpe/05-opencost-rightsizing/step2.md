# Right-size and label

Apply the finance decisions:

1. **Cheapest** (`api-alpha`): add **2 replicas** to its current count
2. **Most expensive** (`api-gamma`): scale to exactly **2 replicas**
3. Label both: `cost.platform.io/adjusted=yes`
4. Leave `api-beta` completely alone

<details><summary>✦ Tip</summary>

"+2 replicas" means *read the current value first*:

```plain
kubectl -n alpha-svc get deploy api-alpha -o jsonpath='{.spec.replicas}'
```{{exec}}

`kubectl scale` sets absolute values — do the addition yourself, or inline it:

```plain
kubectl -n alpha-svc scale deploy api-alpha \
  --replicas=$(( $(kubectl -n alpha-svc get deploy api-alpha -o jsonpath='{.spec.replicas}') + 2 ))
```{{copy}}

</details>

<details><summary>✅ Solution</summary>

```bash
kubectl -n alpha-svc scale deploy api-alpha \
  --replicas=$(( $(kubectl -n alpha-svc get deploy api-alpha -o jsonpath='{.spec.replicas}') + 2 ))
kubectl -n gamma-svc scale deploy api-gamma --replicas=2
kubectl -n alpha-svc label deploy api-alpha cost.platform.io/adjusted=yes
kubectl -n gamma-svc label deploy api-gamma cost.platform.io/adjusted=yes
```{{exec}}

Final check — this is what a grader would look at:

```bash
kubectl get deploy -A -l cost.platform.io/adjusted=yes
```{{exec}}

</details>
