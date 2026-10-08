# Scenario — Create a real static Pod

Book scenario(s): 7.

Inspect the kubelet staticPodPath recorded in `~/book-labs/cka-08-static-pods-logs/static-dir.txt`. Place `book-cka-static.yaml` there with a Pod named `book-cka-static` in namespace `book-cka-hostpods`, image nginx:1.28.0. Let the kubelet create the mirror Pod; do not create this Pod through kubectl apply.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-08-static-pods-logs/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-08-static-pods-logs/solution-step-01.sh
bash /opt/book-labs/cka-08-static-pods-logs/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-08-static-pods-logs/solution.sh`. Every step remains independently verifiable after all solutions finish.
