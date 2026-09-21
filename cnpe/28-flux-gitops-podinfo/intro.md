# Deploy podinfo with Flux

This is the optional Flux route for Chapter 6. Start on a fresh cluster; do not run
Argo CD and Flux against the same target resources.

Create GitRepository `podinfo` and HelmRelease `podinfo-ui` in `flux-system`.
Use `https://github.com/stefanprodan/podinfo`, branch `master`, chart path
`charts/podinfo`, release name `podinfo-ui`, and target namespace `apps-ui`.
Enable namespace creation and Helm drift correction. Set `replicaCount: 2`,
`service.type: ClusterIP`, and `ui.color: "#336699"`. Let Flux deploy the chart;
do not run `helm install` manually.
