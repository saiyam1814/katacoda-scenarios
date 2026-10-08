# Enforce restricted Pod Security Admission

# Scenario

Namespace `book-cks-psa` currently permits an insecure Pod specification. Enforce the `restricted` Pod Security Standard and pin its version to `v1.35`.

Create Pod `worker` using `busybox:1.37.0` and command `sh -c 'sleep 3600'`. It must run as non-root UID `1000`, use `RuntimeDefault` seccomp, disable privilege escalation and drop all Linux capabilities. The Pod must become Ready. A privileged Pod and a host-network Pod must be rejected by admission.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cks-02-pod-security/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.



<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-02-pod-security/solution.sh
bash /opt/book-labs/cks-02-pod-security/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
