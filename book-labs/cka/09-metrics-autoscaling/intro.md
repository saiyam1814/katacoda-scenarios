# CKA — Metrics and CPU autoscaling

We will work through 2 related tasks. Each has a separate CHECK and solution. The resources belong to this lab; setup resets them so you can practise again.

**Environment:** A fresh one-node 4GB kubeadm VM. Setup installs a pinned Metrics Server with verified kubelet TLS and waits for live samples.

Wait for Ready before starting. Check setup without leaving the terminal:

```bash
if test -f /tmp/book-labs/cka-09-metrics-autoscaling/error; then
 cat /tmp/book-labs/cka-09-metrics-autoscaling/error
elif test -f /tmp/book-labs/cka-09-metrics-autoscaling/ready; then
 printf 'Ready. Start the scenario.\n'
else
 printf 'Setup is still running; inspect /tmp/book-labs/cka-09-metrics-autoscaling/setup.log.\n'
fi
```{{exec}}

Files and answer evidence are under `~/book-labs/cka-09-metrics-autoscaling`. Only use this lab in its disposable environment. Read `cleanup.sh` before using it on a shared local test cluster.
