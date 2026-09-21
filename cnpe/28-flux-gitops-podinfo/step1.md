# Create the source and HelmRelease

The GitRepository fetches Git content. The HelmRelease selects the chart and its
values. `releaseName` keeps the Deployment and Service names predictable;
`driftDetection.mode: enabled` repairs changes to Helm-managed resources.

<details><summary>Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/stefanprodan/podinfo
  ref: { branch: master }
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: podinfo-ui
  namespace: flux-system
spec:
  interval: 1m
  targetNamespace: apps-ui
  releaseName: podinfo-ui
  driftDetection:
    mode: enabled
  chart:
    spec:
      chart: charts/podinfo
      reconcileStrategy: Revision
      sourceRef: { kind: GitRepository, name: podinfo }
  values:
    replicaCount: 2
    service: { type: ClusterIP }
    ui: { color: "#336699" }
  install: { createNamespace: true }
EOF
```{{exec}}
</details>
