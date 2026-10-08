# Scenario — Observe mirror-Pod recreation

Book scenario(s): 7.

Delete only the mirror Pod for `book-cka-static`, leaving the host manifest in place. Save its UID before deletion to `~/book-labs/cka-08-static-pods-logs/mirror-before.txt`; wait for a new Ready mirror Pod with a different UID.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-08-static-pods-logs/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-08-static-pods-logs/solution-step-02.sh
bash /opt/book-labs/cka-08-static-pods-logs/solution-step-02.sh
```{{exec}}

The API mirror is not the source of truth. To stop a static Pod, remove its manifest from the watched directory.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-08-static-pods-logs/solution.sh`. Every step remains independently verifiable after all solutions finish.
