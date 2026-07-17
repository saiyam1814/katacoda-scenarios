# Composition complete! 🎉

One `kubectl apply` of a ten-line XR produced a fully-wired Deployment + Service.
That is the platform API pattern Crossplane exists for.

## Key facts to remember

- **XRD** defines the API shape; **Composition** maps it to real resources;
  **XR** is one instance
- `FromCompositeFieldPath` = copy XR field → composed resource field (it is the default
  patch type)
- With provider-kubernetes, the real object hides under
  `spec.forProvider.manifest.…` - path typos are the #1 failure
- Debug chain: XR conditions → composed resource `SYNCED` status → provider logs
- Re-applying a fixed Composition heals existing XRs - no delete needed
- Crossplane v2 favors composition **functions** (`mode: Pipeline`) - the book covers
  how the same patches look there

📖 This lab is **Chapter 14** of the *CNPE Scenarios and Solutions* book.

Next lab: **15 - Expose a platform Claim with Crossplane XRD**.
