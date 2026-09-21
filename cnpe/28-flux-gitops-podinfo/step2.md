# Verify the controller and the workloads

```bash
kubectl -n flux-system wait gitrepository/podinfo --for=condition=Ready --timeout=300s
kubectl -n flux-system wait helmrelease/podinfo-ui --for=condition=Ready --timeout=300s
flux reconcile helmrelease podinfo-ui -n flux-system --with-source
flux get sources git -n flux-system
flux get helmreleases -n flux-system
kubectl -n apps-ui rollout status deploy/podinfo-ui --timeout=300s
kubectl -n apps-ui get deploy podinfo-ui -o jsonpath='{.spec.replicas}{"\n"}'
kubectl -n apps-ui get svc podinfo-ui -o jsonpath='{.spec.type}{"\n"}'
kubectl -n apps-ui get deploy podinfo-ui -o jsonpath="{.spec.template.spec.containers[0].env[?(@.name=='PODINFO_UI_COLOR')].value}"
```{{exec}}

Both Flux resources must report Ready. The remaining checks must return `2`,
`ClusterIP`, and `#336699`. The CHECK button also inspects the source, chart,
namespace creation, and drift-detection settings.
