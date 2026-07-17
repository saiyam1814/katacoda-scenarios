# Supply chain gated! 🎉

Only images signed by the Distroless keyless identity run in this cluster now - and
Kyverno even pinned the verified digest for you.

## Key facts to remember

- `verifyImages` + `attestors.entries.keyless{issuer, subject, rekor.url}` is the
  keyless pattern - the issuer/subject pair **is** the identity
- `validationFailureAction: Enforce` denies; `Audit` only reports
- `webhookTimeoutSeconds: 30` - signature checks do network I/O; the default 10s can
  flake
- Kyverno **autogen** extends Pod rules to Deployments, StatefulSets, Jobs, etc.
- Verified images get **mutated to digests** - expected, and a talking point in reviews
- Keyless = certificate from Fulcio + transparency log in Rekor; no private key to leak

📖 This lab is **Chapter 23** of the *CNPE Scenarios and Solutions* book.

Next lab: **24 - Lock down east-west traffic with Istio AuthorizationPolicy**.
