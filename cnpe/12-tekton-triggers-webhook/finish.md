# Webhook wired! 🎉

A `curl` now does what a human used to: `EventListener` → `TriggerBinding` →
`TriggerTemplate` → `PipelineRun`.

## Key facts to remember

- The trio and their jobs: **Binding** extracts (`$(body.<field>)`), **Template**
  stamps (uses `tt.params.<name>`), **EventListener** listens and needs a
  **ServiceAccount with EventListener RBAC**
- The listener materializes as Deployment/Service **`el-<name>`** on port **8080**
- Debug order: listener logs → `tkn pipelinerun list` → run logs
- GitHub-style pushes put the commit SHA in `body.after` — that is why the binding
  reads exactly that field
- Production listeners add **interceptors** (signature validation, CEL filters) —
  know they exist

📖 This lab is **Chapter 12** of the *CNPE Scenarios and Solutions* book.

Next lab: **13 — Ship a FeatureFlag CRD for the platform API**.
