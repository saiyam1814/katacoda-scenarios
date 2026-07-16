# Self-service unlocked! 🎉

Squads can now `argo submit --from workflowtemplate/deploy-kit -p ...` and get a
deployment without filing a ticket. That is platform engineering in one sentence.

## Key facts to remember

- **WorkflowTemplate** = reusable definition; **Workflow** = one run;
  `argo submit --from workflowtemplate/<name>` connects them
- `resource:` templates run `kubectl <action>` on an inline manifest —
  `action: apply` is idempotent, `create` is not
- Parameters flow: `-p name=value` → `spec.arguments` → entrypoint `inputs.parameters`
- Workflow pods run as `spec.serviceAccountName` — RBAC failures are the #1 cause of
  broken workflows (executor also needs `workflowtaskresults` create/patch)
- Always verify the **artifact** of the workflow (here: the Deployment), not just the
  workflow status

📖 This lab is **Chapter 9** of the *CNPE Scenarios and Solutions* book.

Next lab: **10 — Add a ready-check step to release-checker**.
