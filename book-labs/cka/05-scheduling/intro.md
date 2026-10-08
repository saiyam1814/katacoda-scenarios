# CKA — Selectors, direct binding, affinity and DaemonSets

We will work through 4 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A disposable kubeadm cluster with administrative access.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-05-scheduling/error; then
 cat /tmp/book-labs/cka-05-scheduling/error
elif test -f /tmp/book-labs/cka-05-scheduling/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-05-scheduling/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-05-scheduling`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
