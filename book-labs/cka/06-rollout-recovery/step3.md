# Scenario — Inspect history and recover the broken rollout

Book scenario(s): 14.

Deployment `web` is failing because its second release has an invalid image. Inspect recorded change causes and roll back to the working release. Keep two replicas of `nginx:1.27.5`. Save actual history to `~/book-labs/cka-06-rollout-recovery/history.txt`.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-06-rollout-recovery/verify-step-03.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-06-rollout-recovery/solution-step-03.sh
bash /opt/book-labs/cka-06-rollout-recovery/solution-step-03.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-06-rollout-recovery/solution.sh`. Every step remains independently verifiable after all solutions finish.
