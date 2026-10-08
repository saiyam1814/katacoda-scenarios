# Install and enforce a local seccomp profile

On the node, create `/var/lib/kubelet/seccomp/profiles/book-deny-chmod.json`: default allow, but return EPERM for chmod, fchmod and fchmodat. Create BusyBox Pod `demo` in `book-cks-seccomp` selecting this Localhost profile, sleeping 3600 seconds. It must create and read `/tmp/allowed`; chmod on that file must fail. Do not simulate a denial with Unix ownership or a read-only filesystem.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-03-runtime-hardening/solution.sh
bash /opt/book-labs/cks-03-runtime-hardening/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
