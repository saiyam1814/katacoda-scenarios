# Shipped through GitOps! 🎉

One `Application` object, and Argo CD did the rest: fetched the repo, rendered the
chart with your values, created the namespace, applied everything, and keeps it
reconciled forever.

## Key facts to remember

- `Application` lives in the **argocd namespace**, deploys anywhere
- Helm values: `spec.source.helm.values` (string) or `valuesObject` (structured)
- `CreateNamespace=true` goes under `syncPolicy.syncOptions`
- `automated: {prune: true, selfHeal: true}` = full GitOps (drift correction + deletion)
- `argocd app wait <name> --health --core` waits for the Application to become healthy
- Score comes from **Synced + Healthy + correct values in the live cluster**

📖 This lab is **Chapter 6** of the *CNPE Scenarios and Solutions* book - including the
complete **Flux** solution to the same task.

Next lab: **07 - Roll out media-proxy with a weighted canary**.
