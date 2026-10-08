# Scenario — Co-locate using required Pod affinity

Book scenario(s): 9.

Create Ready Pod anchor using nginx:1.28.0 and label role=anchor. Create Ready Pod `near-anchor` in `book-cka-scheduling`, image `redis:7.4.5`, with required Pod affinity to `role=anchor` on topology key `kubernetes.io/hostname`. Do not set nodeName or a nodeSelector. Keep the anchor Pod.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-05-scheduling/verify-step-03.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-05-scheduling/solution-step-03.sh
bash /opt/book-labs/cka-05-scheduling/solution-step-03.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-05-scheduling/solution.sh`. Every step remains independently verifiable after all solutions finish.
