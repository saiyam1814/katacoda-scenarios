# mTLS-Identity Authorization with Linkerd

**Domain:** Security and Policy Enforcement (bonus lab) &nbsp;|&nbsp; **Suggested time:** 12 minutes

Same audit finding as lab 24 — anyone can call the payment service — but this platform
runs **Linkerd**. Same zero-trust outcome, different (and pleasingly small) model.

The mesh (all namespaces are injected):

- `payments` — Service **`checkout`** (port 8080, label `app: checkout`)
- `web` — Pod `storefront`, ServiceAccount **`storefront`** — the only allowed caller
- `batch` — Pod `reporting`, ServiceAccount `reporting` — must be denied

**Your task:**

1. Create a **Server** named **`checkout`** in `payments` selecting the checkout Pods
   on port **8080** (proxyProtocol `HTTP/1`) — and observe what a Server alone does
   to traffic
2. Authorize **only** ServiceAccount `storefront` (namespace `web`) using a
   **MeshTLSAuthentication** named **`storefront-only`** plus an
   **AuthorizationPolicy** named **`checkout-allow-storefront`**
3. Prove: storefront still works, reporting gets denied by the proxy

Click **START** while Linkerd installs.
