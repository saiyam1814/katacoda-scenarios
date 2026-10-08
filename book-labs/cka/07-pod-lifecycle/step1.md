# Scenario — Create a Pod and extract only its image

Book scenario(s): 2.

In `book-cka-pods`, create Ready Pod `saiyam` with image `nginx:1.28.0`. Save only the image name and newline to `~/book-labs/cka-07-pod-lifecycle/image.txt`. Use structured output instead of copying the wide table.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-07-pod-lifecycle/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-07-pod-lifecycle/solution-step-01.sh
bash /opt/book-labs/cka-07-pod-lifecycle/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-07-pod-lifecycle/solution.sh`. Every step remains independently verifiable after all solutions finish.
