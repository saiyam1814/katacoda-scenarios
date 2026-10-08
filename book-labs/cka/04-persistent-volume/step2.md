# Scenario — Observe Retain after deleting a claim

Book scenario(s): 36.

Create a second local PV book-cka-local-retained for /var/book-labs/cka-local/retained (same class, capacity, access mode and Retain). Bind PVC retained using Pod writer, write retained-after-claim-deletion to retained.txt, save the PVC UID to deleted-claim-uid.txt, then delete writer and its PVC. Leave the PV Released and its data intact. Keep the first exercise running.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-04-persistent-volume/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-04-persistent-volume/solution-step-02.sh
bash /opt/book-labs/cka-04-persistent-volume/solution-step-02.sh
```{{exec}}

Retain leaves storage and the old claim reference for an administrator to handle. Deleting a claim does not make this PV immediately Available.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-04-persistent-volume/solution.sh`. Every step remains independently verifiable after all solutions finish.
