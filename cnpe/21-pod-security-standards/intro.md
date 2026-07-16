# Warn on Baseline PSS across Fleet Namespaces

**Domain:** Security and Policy Enforcement &nbsp;|&nbsp; **Suggested time:** 10 minutes

SecOps wants visibility before enforcement: which of the fleet namespaces
(**`fleet-1` … `fleet-4`**) run Pods that would violate the **baseline**
Pod Security Standard?

**Your task:**

1. Enable Pod Security Admission **warn mode at baseline level** on all four
   namespaces (also set `warn-version=latest`)
2. Trigger the warnings by restarting the Deployments in each namespace
   (rolling restarts are allowed and expected here)
3. Label **only** the namespaces that produced baseline warnings:
   `secops.acme/needs-hardening=true`

**Constraints:**

- Do **not** patch any Deployment specs to silence warnings — this is an audit,
  not a fix
- Do **not** label clean namespaces

Click **START** when ready.
