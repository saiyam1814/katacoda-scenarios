# Ship a FeatureFlag CRD for the Platform API

**Domain:** Platform APIs and Self-Service Capabilities &nbsp;|&nbsp; **Suggested time:** 10 minutes

Product teams want to manage feature flags as Kubernetes objects. This file
(**`/root/checkout-express.yaml`**) is the contract - it **must apply cleanly** once
you are done:

```yaml
apiVersion: toggle.acme.dev/v1beta1
kind: FeatureFlag
metadata:
  name: checkout-express
  namespace: flags-lab
spec:
  key: checkout.express
  enabled: true
  rolloutPercent: 25
```

Build CRD **`featureflags.toggle.acme.dev`**:

- Group **`toggle.acme.dev`**, kind **`FeatureFlag`**, version **`v1beta1`** (served + storage)
- **Namespaced** scope
- Spec schema: `key` (string), `enabled` (boolean), `rolloutPercent` (integer **0–100**) - 
  all three **required**
- Short name **`ff`** (so `kubectl get ff` works)

Invalid values (like `rolloutPercent: 150`) must be **rejected by the API server** - 
that is the whole point of the schema.

Click **START** when ready.
