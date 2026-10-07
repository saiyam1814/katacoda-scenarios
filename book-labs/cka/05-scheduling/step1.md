# Scenario

Pod `reporter` in namespace `book-cka-scheduling` is Pending. One node has label `book-labs.example/disk=ssd`.

Recreate `reporter` with a node selector for that label. Keep its container image and command. Do not remove the node selector and do not set `nodeName` directly. The Pod must become Ready on the labeled node.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cka-05-scheduling/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cka-05-scheduling/solution.sh
bash /opt/book-labs/cka-05-scheduling/solution.sh
```{{exec}}

Use `kubectl describe pod` and the FailedScheduling event. Most scheduling fields cannot be changed on an existing Pod, so recreate the standalone Pod.

</details>
