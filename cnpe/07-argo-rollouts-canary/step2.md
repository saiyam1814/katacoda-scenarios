# Release a new version and watch the weights

Now the fun part. In a second terminal tab, watch the live traffic split - the
`traffic-gen` Pod prints which nginx version served each request (it reads the
version from the response body; the `Server:` *header* would just say `envoy`,
because the sidecar rewrites it):

```plain
kubectl -n release-bay logs traffic-gen -f
```{{exec interrupt}}

Trigger the canary by updating the image:

```bash
kubectl argo rollouts set image media-proxy media-proxy=nginx:1.26 -n release-bay
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

Once the rollout is fully promoted (Healthy, revision 2), scale down the legacy
Deployment - the Rollout owns the service now:

```bash
kubectl -n release-bay scale deploy media-proxy --replicas=0
```{{exec}}

<details><summary>✦ If the rollout seems stuck</summary>

`kubectl argo rollouts get rollout media-proxy -n release-bay` shows the current step.
A `pause: {duration: 30s}` step advances by itself; a bare `pause: {}` waits for
`kubectl argo rollouts promote`. Check the controller logs if weights never change:
`kubectl -n argo-rollouts logs deploy/argo-rollouts --tail=30`

</details>
