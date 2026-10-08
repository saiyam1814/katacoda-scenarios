# CKA 01 — Initialize and join a kubeadm cluster

CKA chapter 1. This is a disposable infrastructure lab. Use the root terminal on controlplane unless the step names another machine. The scenario makes real host and cluster changes.

Setup: 1–3 minutes to reset. Build: approximately 10–20 minutes including package/image downloads; allow 30 minutes practice. Wait for the Ready message before starting.

The supported two-VM image gives each host one CPU. The cluster-building script exempts only kubeadm’s `NumCPU` sizing check for this disposable practice environment; other preflight checks remain enabled.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/infra-01-kubeadm-bootstrap/error; then
  cat /tmp/book-labs/infra-01-kubeadm-bootstrap/error
elif test -f /tmp/book-labs/infra-01-kubeadm-bootstrap/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait, then check again.\n'
fi
```{{exec}}

The book uses Kubernetes 1.35 as its training baseline. Host exercises use the supported Killercoda image version unless this task explicitly creates a pinned cluster. These are original practice tasks based on public documentation.
