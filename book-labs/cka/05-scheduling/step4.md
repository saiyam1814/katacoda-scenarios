# Scenario — Run a DaemonSet on every node

Book scenario(s): 16.

Create DaemonSet `node-web` in `book-cka-scheduling` with image `nginx:1.28.0`. Run one Ready Pod per Ready node, including a control-plane node with its normal NoSchedule taint. Do not use replicas to emulate the result.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-05-scheduling/verify-step-04.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-05-scheduling/solution-step-04.sh
bash /opt/book-labs/cka-05-scheduling/solution-step-04.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-05-scheduling/solution.sh`. Every step remains independently verifiable after all solutions finish.
