# Bind a claim and prove data survives

**CKA scenario | Storage | Suggested time: 12 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Namespace `book-cka-storage` contains Pending PVC `data` and Pod `writer`. A static PV `book-cka-data` is available with capacity `1Gi`, storage class `book-manual` and access mode `ReadWriteOnce`.

Repair the PVC to request `1Gi`, bind it to that PV and start the existing Pod with `/data` mounted from the claim. Write exactly `book-data-survives` to `/data/proof.txt`. The checker creates a second Pod on the same node to confirm that the data is on the volume. Preserve the PV and its `Retain` reclaim policy.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/cka-04-persistent-volume/error; then
  cat /tmp/book-labs/cka-04-persistent-volume/error
elif test -f /tmp/book-labs/cka-04-persistent-volume/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait a moment, then check again.\n'
fi
```{{exec}}
