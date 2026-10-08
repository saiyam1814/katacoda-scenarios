# Use Kubesec findings to repair a manifest

Scan insecure.yaml with Kubesec and save reports/kubesec-before.json. Write repaired.yaml for the same Pod, with non-root UID 1000, RuntimeDefault seccomp, no privilege escalation, no capabilities and a read-only root. Save the actual repaired scan to reports/kubesec-after.json, apply repaired.yaml and ensure the Pod is Ready. The Kubesec critical finding must be removed, not just renamed.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-07-supply-chain/solution.sh
bash /opt/book-labs/cks-07-supply-chain/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
