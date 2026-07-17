# Expose a Platform Claim with Crossplane XRD

**Domain:** Platform APIs and Self-Service Capabilities &nbsp;|&nbsp; **Suggested time:** 14 minutes

App teams want object storage without ever seeing a cloud credential. You will expose a
**namespaced Claim** they can `kubectl apply` like any other resource.

**Your task:**

1. Create XRD **`xbucketapps.platform.example.io`**:
   - Composite kind **`XBucketApp`** (cluster-scoped, version `v1alpha1`,
     served + referenceable)
   - **Claim** kind **`BucketApp`** (this is what makes it namespaced self-service)
   - Spec fields **`region`** and **`size`** - both strings, both required
2. Apply the provided **Composition** (it "provisions" a bucket as a ConfigMap in
   `bucket-system` via provider-kubernetes - same pattern as a real cloud bucket,
   zero cloud bill)
3. As an app team, claim a bucket: **`media-assets`** in namespace **`team-apps`**
   with `region: eu-west-1`, `size: small` - and wait until it is **Ready**

Click **START** while Crossplane installs.
