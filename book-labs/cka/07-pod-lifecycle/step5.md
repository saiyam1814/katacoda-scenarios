# Scenario — Coordinate ordinary containers through a shared volume

Book scenario(s): 18.

Create Pod `shared` in `book-cka-pods` with restartPolicy Never. BusyBox containers `writer` and `reader` share emptyDir `/work`; writer saves `Hello from writer` to `/work/message`, reader waits for the file, prints it and exits successfully. Both containers must terminate with exit 0.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-07-pod-lifecycle/verify-step-05.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-07-pod-lifecycle/solution-step-05.sh
bash /opt/book-labs/cka-07-pod-lifecycle/solution-step-05.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-07-pod-lifecycle/solution.sh`. Every step remains independently verifiable after all solutions finish.
