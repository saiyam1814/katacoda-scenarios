# Wait for Healthy and prove the values

An Application object alone is not the goal — **Synced + Healthy** is.

Watch the status (Ctrl+C when both columns are green):

```plain
kubectl -n argocd get application podinfo-ui -w
```{{exec interrupt}}

Or use the CLI in core mode (no login needed, talks straight to the cluster):

```bash
argocd app wait podinfo-ui --health --sync --timeout 300 --core
```{{exec}}

Then prove the Helm values landed:

```bash
kubectl -n apps-ui get deploy podinfo-ui -o jsonpath='{.spec.replicas}' ; echo " replicas"
kubectl -n apps-ui get svc podinfo-ui -o jsonpath='{.spec.type}' ; echo " service"
kubectl -n apps-ui get deploy podinfo-ui \
  -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_UI_COLOR")].value}' ; echo " color"
```{{exec}}

<details><summary>✦ If the app hangs in Progressing</summary>

- `kubectl -n argocd logs deploy/argocd-repo-server --tail=30` — repo/chart fetch issues
- `kubectl -n apps-ui get pods` — image pulls can take a moment on fresh nodes
- `argocd app get podinfo-ui --core` — shows per-resource health

</details>

<details><summary>✦ How would Flux solve this?</summary>

Same Git repo, two objects instead of one — a `GitRepository` (source) plus a
`HelmRelease` (reconciliation with `values:` and `targetNamespace`). The book chapter
walks through the full Flux equivalent. The exam lets you pick either tool — pick the
one installed in the task's cluster.

</details>
