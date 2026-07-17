# Release and let the metrics decide

Trigger the canary the GitOps way - just change the image on the **original**
Deployment (Flagger watches it):

```bash
kubectl -n release-bay set image deploy/media-proxy media-proxy=nginx:1.26
```{{exec}}

Watch Flagger work through the analysis - every 20s it checks the success rate and,
if healthy, adds 20% weight (this takes ~2–3 minutes to full promotion):

```plain
kubectl -n release-bay get canary media-proxy -w
```{{exec interrupt}}

In a second tab you can watch the actual traffic weights move on the VirtualService:

```plain
watch -n 5 "kubectl -n release-bay get virtualservice media-proxy -o jsonpath='{.spec.http[0].route}'"
```{{exec interrupt}}

And Flagger narrates every decision in its events:

```bash
kubectl -n release-bay get events --field-selector involvedObject.name=media-proxy \
  --sort-by=.lastTimestamp | tail -12
```{{exec}}

You are done when the canary shows **`Succeeded`** and the primary runs 1.26:

```bash
kubectl -n release-bay get canary media-proxy
kubectl -n release-bay get deploy media-proxy-primary \
  -o jsonpath='{.spec.template.spec.containers[0].image}' ; echo
```{{exec}}

<details><summary>✦ What would a BAD release look like?</summary>

If the new version served 5xx errors, `request-success-rate` would drop below 99,
Flagger would halt advancement, and after `threshold: 3` failed checks it would
**roll back to the primary automatically** - canary phase `Failed`, traffic back at
100/0, and your users mostly unharmed. That automatic verdict is exactly what the
fixed `steps:` program in lab 07 cannot give you.

</details>
