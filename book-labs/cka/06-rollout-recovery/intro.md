# Recover a broken Deployment rollout

**CKA scenario | Troubleshooting / Workloads & Scheduling | Suggested time: 10 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Deployment `web` in namespace `book-cka-rollout` used to run two healthy replicas. A new rollout now uses a nonexistent image.

Inspect rollout history and recover the previous working Pod template. Keep two desired replicas. The final image must be `nginx:1.28.0`, with two updated, Ready and available replicas and no old replicas left.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/cka-06-rollout-recovery/error; then
  cat /tmp/book-labs/cka-06-rollout-recovery/error
elif test -f /tmp/book-labs/cka-06-rollout-recovery/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait a moment, then check again.\n'
fi
```{{exec}}
