# Scenario — Provision a CSI volume and retain data across Pod recreation

Book scenario(s): 17.

Create expandable StorageClass book-cka-expandable using local.csi.openebs.io, volgroup=book_cka_csi, storage=lvm, fsType=ext4, WaitForFirstConsumer and Delete. Create1Gi RWO claim data and BusyBox Pod app in book-cka-csi. Write persistent-csi-data to /data/marker.txt, save PVC UID and Pod UID to pvc-uid.txt and first-pod-uid.txt, delete and recreate only the Pod, and read the same data. Leave the claim bound.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-12-csi-volumes/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-12-csi-volumes/solution-step-01.sh
bash /opt/book-labs/cka-12-csi-volumes/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-12-csi-volumes/solution.sh`. Every step remains independently verifiable after all solutions finish.
