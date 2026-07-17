# Create the Canary resource

See what exists before Flagger touches anything:

```plain
kubectl -n release-bay get deploy,svc,virtualservice
```{{exec}}

Just the Deployment - no services, no VirtualService. Flagger will generate all of
that from your Canary spec. That is the big difference from Argo Rollouts (lab 07),
where the Services and VirtualService had to exist first.

<details><summary>✦ Tip - Canary anatomy</summary>

```yaml
spec:
  targetRef:            # what to canary
  service:              # how to expose it (Flagger generates the Services + VS)
  analysis:             # when to advance, what to measure, when to abort
```{{copy}}

`request-success-rate` and `request-duration` are built-in metric templates for the
istio provider - no PromQL needed.

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: media-proxy
  namespace: release-bay
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: media-proxy
  progressDeadlineSeconds: 300
  service:
    port: 80
  analysis:
    interval: 20s
    threshold: 3
    maxWeight: 100
    stepWeight: 20
    metrics:
      - name: request-success-rate
        thresholdRange:
          min: 99
        interval: 1m
EOF
```{{exec}}

Watch Flagger initialize (takes ~1 minute - it builds the primary side):

```plain
kubectl -n release-bay get canary media-proxy -w
```{{exec interrupt}}

Wait for `Initialized`, then look at what Flagger generated:

```plain
kubectl -n release-bay get deploy,svc,virtualservice
```{{exec}}

`media-proxy-primary` now serves the traffic; your original Deployment is scaled to 0
and acts as the *template* for future canaries.

</details>
