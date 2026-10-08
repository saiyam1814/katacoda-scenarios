# Scenario — Expand the mounted ext4 filesystem without losing data

Book scenario(s): 25.

Save the current mounted filesystem size (KiB) to before-kib.txt. Expand the existing data claim from1Gi to2Gi without deleting it. Wait for PVC status capacity2Gi and for the mounted ext4 filesystem to grow. Save the final claim YAML to expanded-pvc.yaml. Verify the original marker and reject a dry-run request to shrink the claim back to1Gi.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-12-csi-volumes/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-12-csi-volumes/solution-step-02.sh
bash /opt/book-labs/cka-12-csi-volumes/solution-step-02.sh
```{{exec}}

The driver extends a real logical volume and the mounted ext4 filesystem. CHECK measures filesystem blocks before and after, in addition to the API capacity and preserved data.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-12-csi-volumes/solution.sh`. Every step remains independently verifiable after all solutions finish.
