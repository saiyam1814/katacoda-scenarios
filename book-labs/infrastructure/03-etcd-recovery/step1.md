# Take and validate a snapshot

The ConfigMap `cka11/before-backup` contains `restore-me`. Take a real etcd snapshot and save it as `/var/backups/cka11.db`. Validate its status with the matching `etcdutl` under `/root/book-labs/infra-03-etcd-recovery/bin`.

The matching host binaries and connection details are prepared. The etcd client uses `https://127.0.0.1:2379`, CA `/etc/kubernetes/pki/etcd/ca.crt`, and healthcheck-client certificate/key in that directory. Keep the snapshot for the next step.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-03-etcd-recovery/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-03-etcd-recovery/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-03-etcd-recovery/verify1.sh
```{{exec}}
