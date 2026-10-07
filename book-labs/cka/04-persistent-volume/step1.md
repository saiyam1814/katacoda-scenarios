# Scenario

Namespace `book-cka-storage` contains Pending PVC `data` and Pod `writer`. A static PV `book-cka-data` is available with capacity `1Gi`, storage class `book-manual` and access mode `ReadWriteOnce`.

Repair the PVC to request `1Gi`, bind it to that PV and start the existing Pod with `/data` mounted from the claim. Write exactly `book-data-survives` to `/data/proof.txt`. The checker creates a second Pod on the same node to confirm that the data is on the volume. Preserve the PV and its `Retain` reclaim policy.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cka-04-persistent-volume/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cka-04-persistent-volume/solution.sh
bash /opt/book-labs/cka-04-persistent-volume/solution.sh
```{{exec}}

This lab uses `hostPath` on an isolated single-node environment for static PV practice. Production storage should use an appropriate CSI driver; hostPath does not move data between nodes.

</details>
