# CKA 27 — Join and fail over three control planes

CKA chapter 27. This is a disposable infrastructure lab. Use the root terminal on controlplane unless the step names another machine. The scenario makes real host and cluster changes.

Setup: approximately 5–10 minutes for image download, initial bootstrap and reset. Practice: 25 minutes. Only one cluster is created in this session. Wait for the Ready message before starting.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/infra-05-ha-control-plane/error; then
  cat /tmp/book-labs/infra-05-ha-control-plane/error
elif test -f /tmp/book-labs/infra-05-ha-control-plane/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait, then check again.\n'
fi
```{{exec}}

The book uses Kubernetes 1.35 as its training baseline. Host exercises use the supported Killercoda image version unless this task explicitly creates a pinned cluster. These are original practice tasks based on public documentation.
