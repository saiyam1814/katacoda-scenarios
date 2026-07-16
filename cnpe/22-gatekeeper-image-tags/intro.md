# Reject Floating Image Tags with Gatekeeper

**Domain:** Security and Policy Enforcement &nbsp;|&nbsp; **Suggested time:** 10 minutes

`:latest` took production down again — nobody knows which "latest" was running.
**Gatekeeper** (OPA) is installed, and the platform team already ships a
**ConstraintTemplate** named **`forbidfloatingtag`** (kind: **`ForbidFloatingTag`**)
whose Rego rejects `:latest` and untagged images.

**Your task:**

1. Create a **Constraint** named **`forbid-floating-tags`** (kind `ForbidFloatingTag`)
   that matches:
   - `Deployment`, `DaemonSet`, `StatefulSet`, `ReplicaSet` (group `apps`)
   - `Job`, `CronJob` (group `batch`)
   - `Pod` (core group)
2. Prove in namespace `tag-lab`:
   - Deployment with `busybox:latest` → **denied**
   - Deployment with untagged `busybox` → **denied**
   - Deployment with `busybox:1.36.1` → **created**

**Remember:** a ConstraintTemplate does nothing until a **Constraint** instantiates it.

Click **START** while Gatekeeper installs.
