# Scenario — Coordinate ordinary containers through a shared volume

Book scenario(s): 18.

Create Pod `shared` in `book-cka-pods` with restartPolicy Never. BusyBox containers c1 and c2 write Hello from c1 container. and Hello from c2 container. to separate files in shared emptyDir /work. Container c3 waits for both files, prints both in order and exits. All three must complete successfully without a startup race.

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
