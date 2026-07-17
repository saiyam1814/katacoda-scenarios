# Unblock metrics-portal without Editing Deployments

**Domain:** Observability and Operations &nbsp;|&nbsp; **Suggested time:** 12 minutes

It is 9:03 on a Monday. The internal `metrics-portal` stack (Deployments **`metrics-ui`**
and **`metrics-db`**) never came up after the weekend change freeze. Pods are Pending
or erroring, dashboards are dark, and the team lead is standing behind you.

**The rules (this is the exam's favorite trick):**

- You may create or change: **ResourceQuota, LimitRange, Secrets, PVCs**
- You may **delete Pods** (they are cattle)
- You may **NOT** edit, patch, scale, restart or delete the two **Deployments**

Bring both Deployments to **Available**.

Click **START** when ready - then find out what is broken before touching anything.
