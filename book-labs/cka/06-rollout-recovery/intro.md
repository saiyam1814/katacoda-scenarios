# Recover a broken Deployment rollout

**CKA scenario | Troubleshooting / Workloads & Scheduling | Suggested time: 10 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Deployment `web` in namespace `book-cka-rollout` used to run two healthy replicas. A new rollout now uses a nonexistent image.

Inspect rollout history and recover the previous working Pod template. Keep two desired replicas. The final image must be `nginx:1.28.0`, with two updated, Ready and available replicas and no old replicas left.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.
