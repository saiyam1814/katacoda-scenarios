# Lock Down East-West Traffic with Istio AuthorizationPolicy

**Domain:** Security and Policy Enforcement &nbsp;|&nbsp; **Suggested time:** 12 minutes

PCI audit finding: *any* workload in the mesh can call the payment service. Fix it with
identity, not IP ranges.

**The mesh (all sidecar-injected):**

- `payments` - Service **`checkout`** (the protected one, port 8080, label `app: checkout`)
- `web` - Pod `storefront` running as ServiceAccount **`storefront`** (the only allowed caller)
- `batch` - Pod `reporting` running as ServiceAccount `reporting` (must be denied)

**Your task:** create **AuthorizationPolicy `checkout-allow-storefront`** in namespace
`payments` that:

- Selects the `checkout` workload
- **Allows** requests only from ServiceAccount `storefront` in namespace `web`
- Denies everything else (know how ALLOW policies behave when no rule matches!)

Then prove both outcomes with live requests.

Click **START** while Istio installs.
