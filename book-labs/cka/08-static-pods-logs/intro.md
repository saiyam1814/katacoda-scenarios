# CKA — Static Pod lifecycle and container logs

We will work through 3 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A disposable single-node kubeadm Linux host with sudo/root access to kubelet files. For local kind tests only, set BOOK_LAB_NODE_CONTAINER to the dedicated control-plane container.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-08-static-pods-logs/error; then
 cat /tmp/book-labs/cka-08-static-pods-logs/error
elif test -f /tmp/book-labs/cka-08-static-pods-logs/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-08-static-pods-logs/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-08-static-pods-logs`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
