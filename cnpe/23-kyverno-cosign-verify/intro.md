# Gate Workloads with Kyverno Cosign Keyless Verify

**Domain:** Security and Policy Enforcement &nbsp;|&nbsp; **Suggested time:** 12 minutes

The supply-chain guild's new rule: **no unsigned images run here**. Kyverno is
installed cluster-wide. Google's Distroless images are Cosign **keyless**-signed - 
they are the reference "good" images.

Create **ClusterPolicy `supply-chain-signoff`** that:

- Applies in **Enforce** mode (denies, not warns)
- Matches **Pods** in every namespace
- Verifies **all images** (`*`) with a **keyless** attestor:
  - Issuer **`https://accounts.google.com`**
  - Subject **`keyless@distroless.iam.gserviceaccount.com`**
  - Rekor **`https://rekor.sigstore.dev`**
- Sets `webhookTimeoutSeconds: 30` (signature checks call out to Rekor) and
  `background: false` (verifyImages is admission-time work)

Then prove in `policy-sandbox`:

- Deployment with `gcr.io/distroless/base:debug-nonroot` → **admitted**
- Deployment with `busybox:1.36` → **denied**

Click **START** while Kyverno installs.
