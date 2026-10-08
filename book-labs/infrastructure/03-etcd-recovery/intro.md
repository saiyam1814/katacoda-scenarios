# CKA 11 — Restore a real etcd snapshot

CKA chapter 11. This is a disposable infrastructure lab. Use the root terminal on controlplane unless the step names another machine. The scenario makes real host and cluster changes.

Setup: 1–3 minutes. Practice: 25 minutes for both steps. Wait for the Ready message before starting.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/infra-03-etcd-recovery/error; then
  cat /tmp/book-labs/infra-03-etcd-recovery/error
elif test -f /tmp/book-labs/infra-03-etcd-recovery/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait, then check again.\n'
fi
```{{exec}}

The book uses Kubernetes 1.35 as its training baseline. Host exercises use the supported Killercoda image version unless this task explicitly creates a pinned cluster. These are original practice tasks based on public documentation.
