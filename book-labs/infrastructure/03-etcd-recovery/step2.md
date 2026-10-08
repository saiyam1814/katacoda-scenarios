# Delete data, restore and prove recovery

Inject the post-backup change:

```bash
bash /opt/book-labs/infra-03-etcd-recovery/prepare2.sh
```{{exec}}

The original ConfigMap is now deleted and `after-backup` exists. Stop all four control-plane static Pods by moving their manifests outside the watched directory. Restore `/var/backups/cka11.db` into `/var/lib/etcd-cka11-restored` with the original etcd member name and advertised peer URL, revision bump 1000000000, and mark-compacted. Point only the etcd-data hostPath to the restored directory; preserve the container mount path and TLS configuration. Return the manifests and recover API access.

Prove `before-backup` returns with its original UID and marker, `after-backup` disappears, and the running etcd uses the restored directory. Keep the old directory and snapshot.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-03-etcd-recovery/solution2.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-03-etcd-recovery/solution2.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-03-etcd-recovery/verify2.sh
```{{exec}}
