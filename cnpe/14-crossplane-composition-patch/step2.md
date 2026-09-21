# Create and inspect the namespaced XR

```bash
kubectl apply -f /root/app-xr.yaml
kubectl -n compose-sandbox wait xwebapp/demo-site --for=condition=Ready --timeout=180s
kubectl -n compose-sandbox get xwebapp,deploy,svc
kubectl -n compose-sandbox rollout status deploy/demo-site --timeout=120s
kubectl -n compose-sandbox get deploy demo-site -o jsonpath='replicas={.spec.replicas} image={.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n compose-sandbox get endpointslice -l kubernetes.io/service-name=demo-site
```{{exec}}

The Deployment must have two available replicas, image `nginx:1.25`, and matching
`app: demo-site` selectors and Pod labels. The Service must have ready endpoints.
If the XR is not ready, describe it, check the function's health, then inspect the
composed resources. Correct the Composition and reapply it.
