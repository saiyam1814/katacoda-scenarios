# GitOps-install podinfo with Argo CD

**Domain:** GitOps and Continuous Delivery &nbsp;|&nbsp; **Suggested time:** 12 minutes

The app team wants `podinfo` on the cluster, and the platform rule is absolute:
**everything ships through GitOps**. Argo CD runs in namespace `argocd`.

Create an Argo CD **Application** named **`podinfo-ui`** (in namespace `argocd`) that:

- Sources the Git repo **`https://github.com/stefanprodan/podinfo`**
- Uses chart path **`charts/podinfo`**, revision **`master`**
- Deploys to the in-cluster destination, namespace **`apps-ui`** (auto-created)
- Sets Helm values:
  - `replicaCount: 2`
  - `service.type: ClusterIP`
  - `ui.color: "#336699"`
- Syncs **automatically** (prune + self-heal) and ends up **Synced / Healthy**

**Constraint:** the Argo CD controller must create the resources - 
running `helm install` or `kubectl apply` on rendered manifests scores **zero**.

Click **START** while Argo CD finishes installing.
