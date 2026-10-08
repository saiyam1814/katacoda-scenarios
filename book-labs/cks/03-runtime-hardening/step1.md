# Harden the live process

# Scenario

Deployment `worker` in `book-cks-runtime` is running with permissive defaults. Harden its Pod template without changing the image or sleep command.

Run as UID and GID `1000`, set `runAsNonRoot: true`, use `RuntimeDefault` seccomp, disable privilege escalation, drop all capabilities and use a read-only root filesystem. Mount a writable `emptyDir` at `/tmp` and set `fsGroup: 1000`. Keep one Ready replica. Do not set privileged mode or add capabilities.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cks-03-runtime-hardening/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.



<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-03-runtime-hardening/solution.sh
bash /opt/book-labs/cks-03-runtime-hardening/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
