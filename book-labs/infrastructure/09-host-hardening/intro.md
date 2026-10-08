# CKS 31 — Harden a real host service

CKS chapter 31. This is a disposable infrastructure lab. Use the root terminal on controlplane unless the step names another machine. The scenario makes real host and cluster changes.

Setup: under 2 minutes. Practice: 18 minutes. Wait for the Ready message before starting.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/infra-09-host-hardening/error; then
  cat /tmp/book-labs/infra-09-host-hardening/error
elif test -f /tmp/book-labs/infra-09-host-hardening/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait, then check again.\n'
fi
```{{exec}}

The book uses Kubernetes 1.35 as its training baseline. Host exercises use the supported Killercoda image version unless this task explicitly creates a pinned cluster. These are original practice tasks based on public documentation.
