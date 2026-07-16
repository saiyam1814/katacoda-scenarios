# Add a ready-check Step to release-checker

**Domain:** GitOps and Continuous Delivery &nbsp;|&nbsp; **Suggested time:** 10 minutes

The `release-checker` Workflow deploys `checkout-api` to staging and then runs smoke
tests — but the tests sometimes fire **before the rollout finishes**. Classic race.

The Workflow definition lives at **`/root/release-checker.yaml`**. It currently runs:

`deploy` → `test`

**Your task — edit the file so that:**

1. A new step **`ready-check`** (using a new template **`wait-ready`**) runs
   **between** `deploy` and `test`
2. The `wait-ready` template uses image **`rancher/kubectl:v1.28.0`** and runs:
   `kubectl rollout status deploy/checkout-api -n stage-coral --timeout=90s`
3. The existing `deploy` and `test` templates are **not renamed or removed**

Then **submit** the Workflow and confirm it **succeeds end-to-end**.

Click **START** when ready.
