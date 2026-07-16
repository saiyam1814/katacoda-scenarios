# Self-service storage API live! 🎉

An app team just `kubectl apply`-ed a nine-line `BucketApp` and the platform did the
rest. Swap the ConfigMap for a real `s3.aws.upbound.io/Bucket` and this is production.

## Key facts to remember

- **XRD `claimNames`** is what turns a platform API into namespaced self-service
- Claim (namespaced) ⇄ XR (cluster-scoped): Crossplane keeps them in sync;
  the XR gets a generated `-<hash>` suffix
- XRD must show **Established** (API served) *and* **Offered** (claims served)
- Tenants get RBAC on the claim kind only — cloud credentials stay in the provider
- `kubectl get bucketapp` in team namespaces is your grader-friendly proof

📖 This lab is **Chapter 15** of the *CNPE Scenarios and Solutions* book.

Next lab: **16 — Wire PromLab and build coral-dashboard (Grafana)**.
