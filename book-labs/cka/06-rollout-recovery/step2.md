# Scenario — Update an image with rolling availability

Book scenario(s): 13.

Update `update-demo` from `nginx:1.27.5` to `nginx:1.28.0`. Keep four replicas; use RollingUpdate with maxUnavailable 0 and maxSurge 1. Wait for complete replacement.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-06-rollout-recovery/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-06-rollout-recovery/solution-step-02.sh
bash /opt/book-labs/cka-06-rollout-recovery/solution-step-02.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-06-rollout-recovery/solution.sh`. Every step remains independently verifiable after all solutions finish.
