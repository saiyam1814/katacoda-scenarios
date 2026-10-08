# Scenario

Namespace `book-cks-psa` currently permits an insecure Pod specification. Enforce the `restricted` Pod Security Standard and pin its version to `v1.35`.

Create Pod `worker` using `busybox:1.37.0` and command `sh -c 'sleep 3600'`. It must run as non-root UID `1000`, use `RuntimeDefault` seccomp, disable privilege escalation and drop all Linux capabilities. The Pod must become Ready. A privileged Pod and a host-network Pod must be rejected by admission.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cks-02-pod-security/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cks-02-pod-security/solution.sh
bash /opt/book-labs/cks-02-pod-security/solution.sh
```{{exec}}

PSA operates at admission. Namespace labels do not evict existing Pods, so create or recreate the workload after enforcing the policy.

</details>
