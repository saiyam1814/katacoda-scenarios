# Build a functioning two-VM cluster

The background setup resets this disposable environment. Build a real Kubernetes v1.35.9 kubeadm cluster on `controlplane` (172.30.1.2) and join `node01` (172.30.2.2). This hosted version uses one worker rather than the book's two workers. Keep the control-plane scheduling taint.

The container runtime is already configured by the VM image. Install matching v1.35.9 packages from the v1.35 repository on both hosts, disable swap, initialize with endpoint `controlplane:6443` and Pod CIDR `10.244.0.0/16`, and install Cilium chart1.20.2 (one operator replica, cluster-pool IPAM, VXLAN tunnel, kube-proxy retained). For this one-CPU hosted control plane, add `--ignore-preflight-errors=NumCPU` to `kubeadm init`; retain the other preflight checks. Join the worker using a freshly generated token.

Create namespace `cka01`. Run `dns-controlplane` and `dns-node01` using `busybox:1.37.0`, `sleep 3600`, and nodeSelectors for their respective nodes; add a control-plane NoSchedule toleration to the first. Prove both Pods resolve `kubernetes.default.svc.cluster.local`.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-01-kubeadm-bootstrap/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-01-kubeadm-bootstrap/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-01-kubeadm-bootstrap/verify1.sh
```{{exec}}
