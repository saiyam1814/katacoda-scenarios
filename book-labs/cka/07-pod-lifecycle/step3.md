# Scenario — Share a Pod network namespace

Book scenario(s): 4.

Create Pod `multi` in `book-cka-pods` containing `web` (nginx:1.28.0) and `database` (redis:7.4.5). Both must run in the same Pod. Check Redis responds through localhost.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-07-pod-lifecycle/verify-step-03.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-07-pod-lifecycle/solution-step-03.sh
bash /opt/book-labs/cka-07-pod-lifecycle/solution-step-03.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-07-pod-lifecycle/solution.sh`. Every step remains independently verifiable after all solutions finish.
