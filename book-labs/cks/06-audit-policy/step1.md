# Scenario

Create `~/book-labs/cks-06-audit-policy/audit-policy.json` using `audit.k8s.io/v1`, kind `Policy`.

For this offline exercise use JSON syntax and only these rule fields: `level`, `verbs`, `resources` and `nonResourceURLs`. Omit only the `RequestReceived` stage. Apply these requirements in first-match order:

1. Log all core `secrets` requests at `Metadata` level, never their bodies.
2. Do not log `/healthz`, `/readyz`, `/livez` or paths beneath them.
3. Log `create`, `update`, `patch`, `delete` requests for `apps/deployments` at `RequestResponse`.
4. Log everything else at `Metadata`.

Do not edit the API server. The verifier evaluates representative events against this supported subset; it does not validate live API-server auditing.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cks-06-audit-policy/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cks-06-audit-policy/solution.sh
bash /opt/book-labs/cks-06-audit-policy/solution.sh
```{{exec}}

Audit policy rules use first-match semantics. Put Secret protection ahead of broad request-body rules. Live auditing additionally needs API-server policy and log flags, mounts, permissions and an observed audit event; those host changes are deliberately outside this file exercise.

</details>
