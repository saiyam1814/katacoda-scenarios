# CKA — Kustomize application and component overlays

We will work through 2 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A fresh one-node kubeadm VM. Setup reads its public kubelet certificate chain; it never copies a private key. No pre-existing Metrics Server.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-03-kustomize/error; then
 cat /tmp/book-labs/cka-03-kustomize/error
elif test -f /tmp/book-labs/cka-03-kustomize/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-03-kustomize/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-03-kustomize`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
