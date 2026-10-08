# Repair a privileged Deployment

In `book-cks-privileged`, repair Deployment `inspector`: one BusyBox 1.37.0 container must run as UID/GID 1000, disallow privilege escalation, drop every capability and use a read-only root filesystem. Remove privileged mode. Preserve the long-running command. Prove the replacement Pod has no effective capabilities and cannot create `/blocked`. Save the final Deployment to `~/book-labs/cks-02-pod-security/inspector.yaml`.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-02-pod-security/solution.sh
bash /opt/book-labs/cks-02-pod-security/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
