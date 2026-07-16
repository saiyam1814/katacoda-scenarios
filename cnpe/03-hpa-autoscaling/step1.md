# Create the HPA

Confirm the app and its resource **requests** first — CPU *utilization* is measured
against requests, so an HPA without requests is arithmetic on nothing:

```plain
kubectl -n edge-web get deploy storefront \
  -o jsonpath='{.spec.template.spec.containers[0].resources}' ; echo
```{{exec}}

Now create the HPA named `storefront` (min 2, max 8, average CPU 60%).

<details><summary>✦ Tip</summary>

One line does it:

```plain
kubectl autoscale --help | head -20
```{{exec}}

If you prefer YAML, the modern API is `autoscaling/v2` — `kubectl explain hpa.spec.metrics --api-version=autoscaling/v2` helps.

</details>

<details><summary>✅ Solution</summary>

The imperative way (on kubectl ≤ 1.33 use `--cpu-percent=60` instead of `--cpu=60%`):

```bash
kubectl -n edge-web autoscale deployment storefront \
  --name=storefront --cpu=60% --min=2 --max=8
```{{exec}}

Or the declarative equivalent (what `autoscale` generates under the hood):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: storefront
  namespace: edge-web
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: storefront
  minReplicas: 2
  maxReplicas: 8
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
```{{copy}}

Then confirm it reads metrics (give it up to a minute):

```plain
kubectl -n edge-web get hpa storefront -w
```{{exec interrupt}}

`cpu: 0%/60%` means metrics flow. `cpu: <unknown>/60%` means trouble —
check `kubectl top pods -n edge-web` and metrics-server.

</details>
