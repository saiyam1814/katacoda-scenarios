# Floating tags banished! 🎉

You turned a dormant ConstraintTemplate into an enforced policy and proved both sides
of it.

## Key facts to remember

- **Two-object model:** ConstraintTemplate (defines kind + Rego) → Constraint
  (instantiates + scopes it). No Constraint = no enforcement
- The Constraint's **kind** comes from `template.spec.crd.spec.names.kind`
- `match.kinds` pairs `apiGroups` with `kinds`; core group is `""`
- Denials happen at admission; the **audit** controller additionally scans existing
  objects (`status.totalViolations`)
- `enforcementAction: warn|dryrun` are the soft modes — read the task, default is deny
- Kyverno solves the same problem policy-as-YAML instead of Rego — next-next lab

📖 This lab is **Chapter 22** of the *CNPE Scenarios and Solutions* book.

Next lab: **23 — Gate workloads with Kyverno Cosign keyless verify**.
