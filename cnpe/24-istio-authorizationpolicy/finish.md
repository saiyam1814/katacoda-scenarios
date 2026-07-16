# Zero trust, delivered! 🎉

`checkout` now trusts an **identity**, not a network location. IPs change; SPIFFE IDs
don't.

## Key facts to remember

- Principal format: `cluster.local/ns/<ns>/sa/<serviceaccount>` — memorize it
- **ALLOW policy selected + no rule match = deny.** No catch-all DENY needed
- No policy on a workload = allow all (mesh default)
- Empty `rules: []` on an ALLOW policy = deny **everything** for that workload
- Principals require **mTLS** (sidecars handle it; STRICT PeerAuthentication makes it
  mandatory)
- `RBAC: access denied` = the sidecar speaking, not your app
- Debug: `istioctl analyze`, `istioctl proxy-config`, sidecar logs

📖 This lab is **Chapter 24** of the *CNPE Scenarios and Solutions* book.

Final lab: **25 — Fail the pipeline when an image has CRITICAL CVEs**.
