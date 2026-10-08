# Recover the failed member

Start `book-ha-control-plane` again. Wait for all three nodes and etcd members to recover. Do not stop a second member. Confirm the ConfigMap written during the outage remains available.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-05-ha-control-plane/solution3.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-05-ha-control-plane/solution3.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-05-ha-control-plane/verify3.sh
```{{exec}}
