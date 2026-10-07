# Enforce restricted Pod Security Admission

**CKS scenario | Minimize Microservice Vulnerabilities | Suggested time: 12 minutes**

This is an original practice scenario. It follows public Kubernetes objectives and is not a recalled exam question.

Namespace `book-cks-psa` currently permits an insecure Pod specification. Enforce the `restricted` Pod Security Standard and pin its version to `v1.35`.

Create Pod `worker` using `busybox:1.37.0` and command `sh -c 'sleep 3600'`. It must run as non-root UID `1000`, use `RuntimeDefault` seccomp, disable privilege escalation and drop all Linux capabilities. The Pod must become Ready. A privileged Pod and a host-network Pod must be rejected by admission.

Wait for **Ready** in the terminal, then start. Setup resets this lab's own resources; use an isolated practice cluster.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/cks-02-pod-security/error; then
  cat /tmp/book-labs/cks-02-pod-security/error
elif test -f /tmp/book-labs/cks-02-pod-security/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait a moment, then check again.\n'
fi
```{{exec}}
