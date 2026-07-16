# Create the AuthorizationPolicy

First, see the open door — the intruder can call checkout:

```bash
kubectl -n batch exec reporting -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname ; echo
```{{exec}}

Now close it. Workload identity in Istio is **SPIFFE**-shaped:
`cluster.local/ns/<namespace>/sa/<serviceaccount>` — that string goes into
`source.principals`. Principals come from mTLS peer certificates, which sidecars
exchange automatically.

<details><summary>✦ Tip — ALLOW semantics</summary>

When **any** ALLOW policy selects a workload, everything not matched by one of its
rules is **denied**. So one ALLOW policy for storefront is simultaneously the deny-all
for everyone else. (A workload with **no** policy allows everything — that is the
default you just witnessed.)

</details>

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: checkout-allow-storefront
  namespace: payments
spec:
  selector:
    matchLabels:
      app: checkout
  action: ALLOW
  rules:
    - from:
        - source:
            principals:
              - "cluster.local/ns/web/sa/storefront"
EOF
```{{exec}}

```plain
kubectl -n payments get authorizationpolicy
```{{exec}}

</details>
