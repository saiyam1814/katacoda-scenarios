# Scenario — Repair a node selector

Book scenario(s): 5.

Label the worker listed in node.txt with book-labs.example/disk=ssd. Recreate `reporter` in `book-cka-scheduling` using `busybox:1.37.0`, requiring `book-labs.example/disk=ssd`. Keep it running. Let the scheduler select the node; do not set nodeName.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-05-scheduling/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-05-scheduling/solution-step-01.sh
bash /opt/book-labs/cka-05-scheduling/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-05-scheduling/solution.sh`. Every step remains independently verifiable after all solutions finish.
