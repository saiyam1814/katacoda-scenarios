# Repair a Pod that cannot be scheduled

**CKA scenario | Workloads & Scheduling / Troubleshooting | Suggested time: 8 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Pod `reporter` in namespace `book-cka-scheduling` is Pending. One node has label `book-labs.example/disk=ssd`.

Recreate `reporter` with a node selector for that label. Keep its container image and command. Do not remove the node selector and do not set `nodeName` directly. The Pod must become Ready on the labeled node.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.
