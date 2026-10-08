# Join two real control-plane members

This 4 GB lab uses three actual Kubernetes node containers on one VM. `book-ha-control-plane` is initialized; `book-ha-control-plane2` and `book-ha-control-plane3` have been reset and are ready to join. The TCP load balancer is `book-ha-external-load-balancer:6443`. These are real kubeadm/etcd processes, but the shared VM and single load balancer are lab simplifications, not independent production failure domains.

Generate a fresh token and certificate upload key on the first control plane. Run `kubeadm join --control-plane` inside the other two node containers, one at a time, using their own container IP as the advertised address. Use `/root/book-labs/infra-05-ha-control-plane/kubeconfig` with kubectl. Prove all three nodes and all three stacked etcd members are healthy.

For this nested-container lab, include `--ignore-preflight-errors=SystemVerification` on the join command. The provider kernel does not expose its kernel configuration module inside the node containers. The initial kind bootstrap has already run Kubernetes on that kernel; all other kubeadm preflight checks remain enabled. On independent production hosts, resolve system verification errors instead of applying this lab exception.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-05-ha-control-plane/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-05-ha-control-plane/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-05-ha-control-plane/verify1.sh
```{{exec}}
