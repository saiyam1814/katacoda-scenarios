# CKA 10 + CKS 07 — Upgrade both kubeadm nodes

CKA chapter 10 and CKS chapter 7. This is a disposable infrastructure lab. Use the root terminal on controlplane unless the step names another machine. The scenario makes real host and cluster changes.

Setup: approximately 10–15 minutes for the fresh v1.34.12 cluster and package downloads. Practice: 25–30 minutes. The free-session time budget is tight on a slow image mirror. Wait for the Ready message before starting.

The supported two-VM image gives each host one CPU. The cluster-building script exempts only kubeadm’s `NumCPU` sizing check for this disposable practice environment; other preflight checks remain enabled.

The hosted network uses an underlay MTU of 1450. The Cilium installation matches the provider’s working VXLAN settings: UDP port 4789 and an explicit Cilium MTU setting of 1400. These settings are specific to this hosted environment; use the network requirements of your own machines elsewhere.

If you see a prompt without the Ready message, check setup:

```bash
if test -f /tmp/book-labs/infra-02-cluster-upgrade/error; then
  cat /tmp/book-labs/infra-02-cluster-upgrade/error
elif test -f /tmp/book-labs/infra-02-cluster-upgrade/ready; then
  printf 'Ready. Start the scenario.\n'
else
  printf 'Setup is still running. Wait, then check again.\n'
fi
```{{exec}}

The book uses Kubernetes 1.35 as its training baseline. Host exercises use the supported Killercoda image version unless this task explicitly creates a pinned cluster. These are original practice tasks based on public documentation.
