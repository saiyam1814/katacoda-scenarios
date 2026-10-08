# Upgrade the control plane by one minor

Setup builds a separate v1.34.12 cluster with Cilium1.20.2 and a two-replica `upgrade-check/web` Deployment, a disruption budget requiring one available replica, and a control-plane toleration so maintenance can move the application between hosts. Upgrade the control plane to v1.35.9 first. Use the v1.35 package repository, upgrade kubeadm, inspect the plan, then run `kubeadm upgrade apply`. Drain the control plane before upgrading its kubelet and kubectl, then restart kubelet and uncordon. The worker must remain v1.34.12 for this check.

A real etcd snapshot was taken at `/var/backups/before-upgrade.db`. Never use this procedure as an in-place downgrade; the background setup reset the disposable VMs before constructing its older starting cluster.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-02-cluster-upgrade/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-02-cluster-upgrade/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-02-cluster-upgrade/verify1.sh
```{{exec}}
