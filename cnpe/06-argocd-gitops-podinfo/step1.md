# Create the Application

Confirm Argo CD is up:

```plain
kubectl -n argocd get pods
```{{exec}}

Now write the `Application`. The kind is `argoproj.io/v1alpha1` and the important
blocks are `source` (repo, path, revision, helm values), `destination`
(server + namespace) and `syncPolicy`.

<details><summary>✦ Tip 1 — where do Helm values go?</summary>

Inside `spec.source.helm.values` as an **inline YAML string** (note the `|`):

```yaml
helm:
  values: |
    replicaCount: 2
```{{copy}}

`valuesObject` also works in current Argo CD and avoids the string quoting.

</details>

<details><summary>✦ Tip 2 — the namespace does not exist</summary>

Do not create `apps-ui` by hand. Let Argo CD do it:

```yaml
syncPolicy:
  syncOptions:
    - CreateNamespace=true
```{{copy}}

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: podinfo-ui
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/stefanprodan/podinfo
    targetRevision: master
    path: charts/podinfo
    helm:
      values: |
        replicaCount: 2
        service:
          type: ClusterIP
        ui:
          color: "#336699"
  destination:
    server: https://kubernetes.default.svc
    namespace: apps-ui
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
```{{exec}}

</details>
