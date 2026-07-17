# Prove allow and deny

Policies propagate to sidecars in a few seconds. Then:

**The legit caller** (ServiceAccount `storefront`) still works:

```bash
kubectl -n web exec storefront -- \
  curl -s --max-time 5 http://checkout.payments.svc:8080/hostname ; echo
```{{exec}}

**The intruder** (ServiceAccount `reporting`) gets Istio's 403:

```bash
kubectl -n batch exec reporting -- \
  curl -s --max-time 5 http://checkout.payments.svc:8080/hostname ; echo
```{{exec}}

Expected: `RBAC: access denied` - that string comes from the checkout **sidecar**,
which rejected the peer certificate's identity before the request touched the app.

<details><summary>✦ Both blocked? Neither blocked?</summary>

- **Both blocked:** principals need mTLS. Are all pods really sidecar-injected?
  `kubectl get pods -n web -o jsonpath='{.items[0].spec.containers[*].name}'`
  should list `istio-proxy`
- **Neither blocked:** did the policy land in the **payments** namespace with the
  right `selector`? `istioctl analyze -n payments` finds typos
- Policy changes take a few seconds to reach sidecars - retry once before debugging
- A connection opened **before** the policy can keep answering until Envoy drains
  it (up to ~45s) - an intruder curl that still succeeds right after `apply` is
  usually just that stale connection. Wait and retry.

</details>

<details><summary>✦ Bonus - see the identity in the certificate</summary>

```bash
istioctl proxy-config secret deploy/checkout -n payments | head -5
```{{exec}}

The SPIFFE URI in that cert is exactly what `principals` matches against.

</details>
