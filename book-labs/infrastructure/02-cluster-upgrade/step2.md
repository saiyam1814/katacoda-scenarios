# Upgrade the worker and check the application

Drain `node01`, upgrade its kubeadm package to v1.35.9, run `kubeadm upgrade node` on that worker, then upgrade its kubelet/kubectl, restart kubelet, and uncordon. Save final node versions to `/tmp/cka10-versions.txt`. Both nodes, the API server and the pre-existing application must remain healthy.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-02-cluster-upgrade/solution2.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-02-cluster-upgrade/solution2.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-02-cluster-upgrade/verify2.sh
```{{exec}}
