# Verify the official kubectl binary before using it

Download Kubernetes kubectl v1.35.0 for linux/amd64 and its official checksum from dl.k8s.io. Verify it before installing at the work directory bin/kubectl. Save the downloaded checksum as kubectl.sha256. Keep a modified binary as kubectl.tampered and prove the same expected digest rejects it. Do not replace the system kubectl.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-07-supply-chain/solution.sh
bash /opt/book-labs/cks-07-supply-chain/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
