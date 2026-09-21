# Release a new version and watch the weights

During practice, In a second terminal tab, watch the live traffic split - the
`traffic-gen` Pod prints which nginx version served each request (it reads the
version from the response body; the `Server:` *header* would just say `envoy`,
because the sidecar rewrites it):

```plain
kubectl -n release-bay logs traffic-gen -f
```{{exec interrupt}}

Trigger the canary by updating the image:

```bash
kubectl -n release-bay set image deployment/media-proxy media-proxy=nginx:1.26
```{{exec}}

Watch the rollout walk the steps - 20%, pause, 40%, pause, 100%:

```plain
kubectl argo rollouts get rollout media-proxy -n release-bay --watch
```{{exec interrupt}}

You can also inspect what Argo Rollouts is doing to the VirtualService weights:

```bash
kubectl -n release-bay get virtualservice media-proxy \
  -o jsonpath='{.spec.http[0].route}' | python3 -m json.tool
```{{exec}}

Once the rollout is fully promoted, confirm that the referenced Deployment is
scaled to zero by the controller:

```bash
kubectl -n release-bay get deploy media-proxy -o jsonpath='{.spec.replicas}'
```{{exec}}

<details><summary>✦ If the rollout seems stuck</summary>

`kubectl argo rollouts get rollout media-proxy -n release-bay` shows the current step.
A `pause: {duration: 30s}` step advances by itself; a bare `pause: {}` waits for
`kubectl argo rollouts promote`. Check the controller logs if weights never change:
`kubectl -n argo-rollouts logs deploy/argo-rollouts --tail=30`

</details>

Use the supplied Rollouts dashboard link for a visual revision and step view.
For local practice, run `kubectl argo rollouts dashboard -n release-bay`.
