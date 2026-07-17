# Apply the XR and watch it compose

Apply the composite resource:

```bash
kubectl apply -f /root/app-xr.yaml
```{{exec}}

Trace the chain - XR → composed Objects → real Deployment/Service:

```bash
kubectl get xwebapp demo-site
kubectl get objects.kubernetes.crossplane.io
kubectl -n compose-sandbox get deploy,svc
```{{exec}}

Wait for everything to go Ready:

```bash
kubectl wait xwebapp/demo-site --for=condition=Ready --timeout=180s
kubectl -n compose-sandbox rollout status deploy/demo-site --timeout=120s
```{{exec}}

Prove the patches did their job:

```bash
kubectl -n compose-sandbox get deploy demo-site \
  -o jsonpath='replicas={.spec.replicas} image={.spec.template.spec.containers[0].image}' ; echo
```{{exec}}

<details><summary>✦ If the XR never goes Ready</summary>

Debug down the chain, not up:

1. `kubectl describe xwebapp demo-site` - composition selected? events?
2. `kubectl get objects.kubernetes.crossplane.io` - `SYNCED=False`? describe it;
   the error is usually a bad `toFieldPath`
3. `kubectl -n crossplane-system logs deploy/crossplane --tail=20` - core issues
4. Fix `/root/composition.yaml`, re-apply - Crossplane reconciles existing XRs
   automatically

</details>
