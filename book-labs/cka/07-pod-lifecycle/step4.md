# Scenario — Use a native sidecar for shared logs

Book scenario(s): 4.

Create Pod `log-demo` in `book-cka-pods` with native sidecar `log-reader` under initContainers and restartPolicy Always. Both containers use busybox:1.37.0. A writer repeatedly appends `learning Kubernetes` to shared emptyDir `/logs/app.log`; the sidecar tails it.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-07-pod-lifecycle/verify-step-04.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-07-pod-lifecycle/solution-step-04.sh
bash /opt/book-labs/cka-07-pod-lifecycle/solution-step-04.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-07-pod-lifecycle/solution.sh`. Every step remains independently verifiable after all solutions finish.
