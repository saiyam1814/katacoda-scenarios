# Repair the broken certificate path and inspect interfaces

The API server cannot start. Use `crictl` and the host files to find the incorrect client-CA path in `/etc/kubernetes/manifests/kube-apiserver.yaml`. Fix only the bad field. The backup is under `/root/book-labs/infra-06-api-repair`.

After recovery, create namespace `cka37` and a `busybox:1.37.0` Pod named `verify`, running `sleep 3600`. Prove it resolves `kubernetes.default.svc.cluster.local`. Save the live container runtime version, actual CNI configuration filenames, and installed CSI driver names (or explicitly `none`) as JSON keys `runtime`, `cni_files`, and `csi_drivers` in `/tmp/cka37-interfaces.json`.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-06-api-repair/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-06-api-repair/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-06-api-repair/verify1.sh
```{{exec}}
