# CKA + CKS — Recover, drain and protect a worker

CKA chapters 20 and 23; CKS chapter 24. This is a disposable infrastructure lab. Use the root terminal on controlplane unless the step names another machine. The scenario makes real host and cluster changes.

Setup: 2–4 minutes, including heartbeat timeout. Practice: about 40 minutes across the steps. Wait for the Ready message before starting.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/infra-04-worker-operations/error; then
  cat /tmp/book-labs/infra-04-worker-operations/error
elif test -f /tmp/book-labs/infra-04-worker-operations/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait, then check again.\n'
fi
```{{exec}}

The book uses Kubernetes 1.35 as its training baseline. Host exercises use the supported Killercoda image version unless this task explicitly creates a pinned cluster. These are original practice tasks based on public documentation.
