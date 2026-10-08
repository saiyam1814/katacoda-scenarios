# Keep an HTTP server working with a read-only root

Create Deployment `web` and Service `web` in `book-cks-readonly`. Use BusyBox 1.37.0 to serve `/etc` on port 8080 as UID/GID 1000. Set RuntimeDefault seccomp, no privilege escalation, no capabilities and a read-only root filesystem; mount a writable emptyDir at `/tmp`. Keep `/tmp` as the only writable scratch mount. Prove HTTP `/hostname` works, `/tmp` is writable and `/etc/book-denied` cannot be created because the root filesystem is read-only. Check the running HTTP process has UID/GID1000, no effective or bounding capabilities, no-new-privileges enabled and an active seccomp filter.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-03-runtime-hardening/solution.sh
bash /opt/book-labs/cks-03-runtime-hardening/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
