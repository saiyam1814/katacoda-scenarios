# Create the Application

Confirm Argo CD is up:

```plain
kubectl -n argocd get pods
```{{exec}}

You can create the Application in the UI. For this practice cluster:

```bash
kubectl -n argocd port-forward --address 0.0.0.0 svc/argocd-server 8080:443 >/dev/null 2>&1 &
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```{{exec}}

Open [Argo CD on port 8080]({{TRAFFIC_HOST1_8080}}), log in as `admin`, and choose
**New App**. Set name `podinfo-ui`, project `default`, the Git repository
`https://github.com/stefanprodan/podinfo`, revision `master`, and path
`charts/podinfo`. Use destination cluster `https://kubernetes.default.svc` and
namespace `apps-ui`. Enable automated sync, prune, self-heal, and auto-create
namespace. In the Helm values editor enter:

```yaml
replicaCount: 2
service:
  type: ClusterIP
ui:
  color: "#336699"
```{{copy}}

Create the Application, then inspect its sync and health status. Use a supplied
direct UI link when your environment provides one.

The manifest below is an equivalent route. The independent Flux alternative is
scenario **28**, which should run on a fresh cluster.

Now write the `Application`. The kind is `argoproj.io/v1alpha1` and the important
blocks are `source` (repo, path, revision, helm values), `destination`
(server + namespace) and `syncPolicy`.

<details><summary>✦ Tip 1 - where do Helm values go?</summary>

Inside `spec.source.helm.values` as an **inline YAML string** (note the `|`):

```yaml
helm:
  values: |
    replicaCount: 2
```{{copy}}

`valuesObject` also works in current Argo CD and avoids the string quoting.

</details>

<details><summary>✦ Tip 2 - the namespace does not exist</summary>

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
