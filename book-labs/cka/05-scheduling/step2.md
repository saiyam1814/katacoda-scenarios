# Scenario — Assign a Pod directly to a node

Book scenario(s): 6.

Create `direct` in `book-cka-scheduling` using `nginx:1.28.0`, with explicit `spec.nodeName` equal to the node listed in `~/book-labs/cka-05-scheduling/node.txt`. Save its submitted manifest as `direct.yaml` in that directory. This task deliberately bypasses scheduling.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-05-scheduling/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-05-scheduling/solution-step-02.sh
bash /opt/book-labs/cka-05-scheduling/solution-step-02.sh
```{{exec}}

Direct binding does not make an unhealthy node usable. Compare this with the scheduler event in the previous task.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-05-scheduling/solution.sh`. Every step remains independently verifiable after all solutions finish.
