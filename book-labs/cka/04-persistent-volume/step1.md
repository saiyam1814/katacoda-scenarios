# Scenario — Bind a genuine static local volume

Book scenario(s): 36.

On the node named in node.txt, setup created /var/book-labs/cka-local/data containing marker.txt. Create StorageClass book-cka-local (no provisioner, WaitForFirstConsumer), PV book-cka-local-data (local path, node affinity, 1Gi, RWO, Retain), PVC data and a BusyBox reader in book-cka-storage. Read the existing marker from the mounted claim. Use a local PV, not a hostPath PV.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-04-persistent-volume/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-04-persistent-volume/solution-step-01.sh
bash /opt/book-labs/cka-04-persistent-volume/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-04-persistent-volume/solution.sh`. Every step remains independently verifiable after all solutions finish.
