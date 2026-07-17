# Watch it scale under load

The exam usually stops at "create the HPA and verify it reads metrics" - but seeing a
scale-out once makes the mechanism stick forever.

Generate load against the service (runs for ~3 minutes in the background):

```bash
kubectl -n edge-web run load-gen --image=busybox:1.36 --restart=Never -- \
  /bin/sh -c "for i in \$(seq 1 180); do wget -q -O- http://storefront.edge-web.svc >/dev/null 2>&1; done; sleep 3600"
```{{exec}}

Actually, one wget loop is too gentle. Run four parallel workers:

```bash
for w in 1 2 3 4; do
  kubectl -n edge-web run load-gen-$w --image=busybox:1.36 --restart=Never -- \
    /bin/sh -c "while true; do wget -q -O- http://storefront.edge-web.svc >/dev/null 2>&1; done" 2>/dev/null
done
```{{exec}}

Watch the HPA react (CPU climbs above 60%, replicas grow - takes 1–2 minutes):

```plain
kubectl -n edge-web get hpa storefront -w
```{{exec interrupt}}

When you have seen replicas increase past 2, stop the load:

```bash
kubectl -n edge-web delete pod load-gen load-gen-1 load-gen-2 load-gen-3 load-gen-4 --ignore-not-found --now
```{{exec}}

<details><summary>✦ Why does scale-down take so long?</summary>

Scale-up reacts quickly; scale-down waits out a **5-minute stabilization window**
(`--horizontal-pod-autoscaler-downscale-stabilization`) to avoid flapping.
You do not need to wait for it - the verify check only requires that the HPA
successfully read metrics and scaled up at least once.

</details>
