# Order audit rules without logging Secret bodies

**CKS scenario | Monitoring, Logging & Runtime Security | Suggested time: 15 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Create `~/book-labs/cks-06-audit-policy/audit-policy.json` using `audit.k8s.io/v1`, kind `Policy`.

For this offline exercise use JSON syntax and only these rule fields: `level`, `verbs`, `resources` and `nonResourceURLs`. Omit only the `RequestReceived` stage. Apply these requirements in first-match order:

1. Log all core `secrets` requests at `Metadata` level, never their bodies.
2. Do not log `/healthz`, `/readyz`, `/livez` or paths beneath them.
3. Log `create`, `update`, `patch`, `delete` requests for `apps/deployments` at `RequestResponse`.
4. Log everything else at `Metadata`.

Do not edit the API server. The verifier evaluates representative events against this supported subset; it does not validate live API-server auditing.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.
