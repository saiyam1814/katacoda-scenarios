# Storage unblocked! 🎉

You practiced the classic CNPE storage flow:

1. **Read the cluster first** - claim names live in the Deployment spec, class names in `kubectl get sc`
2. **Map requirements to classes** - "high-IOPS" was a *hint*, not a class name
3. **Respect constraints** - no Deployment or StorageClass edits needed

## Key facts to remember

- `WaitForFirstConsumer` PVCs stay `Pending` until a Pod consumes them - not a bug
- A PVC's StorageClass and size are **immutable** once bound (size can only grow, and
  only if the class allows expansion)
- The event `persistentvolumeclaim not found` on a Pod is your signal to create a claim,
  not to touch the workload

📖 This lab is **Chapter 2** of the *CNPE Scenarios and Solutions* book.

Next lab: **03 - Autoscale a frontend with HorizontalPodAutoscaler**.
