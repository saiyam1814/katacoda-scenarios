# Harden a workload and check the running process

**CKS scenario | Minimize Microservice Vulnerabilities / System Hardening | Suggested time: 12 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Deployment `worker` in `book-cks-runtime` is running with permissive defaults. Harden its Pod template without changing the image or sleep command.

Run as UID and GID `1000`, set `runAsNonRoot: true`, use `RuntimeDefault` seccomp, disable privilege escalation, drop all capabilities and use a read-only root filesystem. Mount a writable `emptyDir` at `/tmp` and set `fsGroup: 1000`. Keep one Ready replica. Do not set privileged mode or add capabilities.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.
