# Scenario — Use ConfigMap and Secret references

Book scenario(s): 26.

In `book-cka-config`, create ConfigMap `demo` with colour=green, name=saiyam, exam=cka and Secret `cka-demo`, key password, value training-only-password. Create `demo-pod` (busybox:1.37.0) importing ConfigMap keys as environment, mounting the same ConfigMap read-only at `/etc/config`, and sourcing DATABASE_PASSWORD through secretKeyRef. Tolerate book-labs.example/pool=apps:NoSchedule.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-10-probes-configuration/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-10-probes-configuration/solution-step-01.sh
bash /opt/book-labs/cka-10-probes-configuration/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-10-probes-configuration/solution.sh`. Every step remains independently verifiable after all solutions finish.
