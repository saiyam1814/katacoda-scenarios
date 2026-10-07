# Scenario

Deployment `web` in namespace `book-cka-rollout` used to run two healthy replicas. A new rollout now uses a nonexistent image.

Inspect rollout history and recover the previous working Pod template. Keep two desired replicas. The final image must be `nginx:1.28.0`, with two updated, Ready and available replicas and no old replicas left.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cka-06-rollout-recovery/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cka-06-rollout-recovery/solution.sh
bash /opt/book-labs/cka-06-rollout-recovery/solution.sh
```{{exec}}

Rollback restores the Pod template, not every Deployment setting. Check replica counts and rollout status after undo.

</details>
