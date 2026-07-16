# Platform API shipped! 🎉

You extended the Kubernetes API itself — the foundation of every platform abstraction
(Crossplane XRDs included, as you will see in the next two labs).

## Key facts to remember

- CRD name **must** be `<plural>.<group>` — mismatch = instant rejection
- Exactly **one version** with `storage: true`
- `required:` sits on the **object**, `minimum`/`maximum` on the **property**
- `shortNames` gives you `kubectl get ff`; check with `kubectl api-resources | grep -i flag`
- Wait for condition **Established** before applying CRs in scripts
- Schema validation is free protection — no controller needed to reject bad input

📖 This lab is **Chapter 13** of the *CNPE Scenarios and Solutions* book.

Next lab: **14 — Patch an XWebApp Composition in Crossplane**.
