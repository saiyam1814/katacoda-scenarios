# Authorize exactly one identity

Linkerd identities are DNS-like names minted from ServiceAccounts:

```
<serviceaccount>.<namespace>.serviceaccount.identity.linkerd.cluster.local
```

Two objects wire the authorization: a **MeshTLSAuthentication** (who) and an
**AuthorizationPolicy** (may talk to which Server).

<details><summary>✅ Solution</summary>

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: policy.linkerd.io/v1alpha1
kind: MeshTLSAuthentication
metadata:
  name: storefront-only
  namespace: payments
spec:
  identities:
    - "storefront.web.serviceaccount.identity.linkerd.cluster.local"
---
apiVersion: policy.linkerd.io/v1alpha1
kind: AuthorizationPolicy
metadata:
  name: checkout-allow-storefront
  namespace: payments
spec:
  targetRef:
    group: policy.linkerd.io
    kind: Server
    name: checkout
  requiredAuthenticationRefs:
    - group: policy.linkerd.io
      kind: MeshTLSAuthentication
      name: storefront-only
EOF
```{{exec}}

</details>

Prove both outcomes:

```bash
echo "storefront (should answer):"
kubectl -n web exec storefront -c curl -- curl -s --max-time 5 http://checkout.payments.svc:8080/hostname ; echo
echo "reporting (should be denied):"
kubectl -n batch exec reporting -c curl -- curl -sw ' HTTP:%{http_code}' --max-time 5 http://checkout.payments.svc:8080/hostname ; echo
```{{exec}}

The reporting caller gets a `403` from checkout's **linkerd-proxy** - the request
never reaches the app, and the decision was made on the caller's mTLS certificate.

<details><summary>✦ Compare with the Istio lab (24)</summary>

| | Istio | Linkerd |
|---|---|---|
| Identity | `cluster.local/ns/web/sa/storefront` | `storefront.web.serviceaccount.identity.linkerd.cluster.local` |
| Objects | AuthorizationPolicy (selector + principals) | Server + MeshTLSAuthentication + AuthorizationPolicy |
| Default when policy exists | ALLOW-selected = everything else denied | Server present = deny until authorized |

Different YAML, same idea: **authorize identities, not IPs.**

</details>
