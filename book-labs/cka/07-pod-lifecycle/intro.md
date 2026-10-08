# CKA — Pods, init containers, sidecars and shared files

We will work through 5 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A disposable kubeadm cluster with administrative access.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-07-pod-lifecycle/error; then
 cat /tmp/book-labs/cka-07-pod-lifecycle/error
elif test -f /tmp/book-labs/cka-07-pod-lifecycle/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-07-pod-lifecycle/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-07-pod-lifecycle`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
