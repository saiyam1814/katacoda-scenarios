# Prove writes survive one unavailable member

Stop only the first control-plane container with `docker stop book-ha-control-plane`. Keep both other members and the external load balancer running. Through the load-balanced kubeconfig, create and read a ConfigMap in `cka27-check`. Leave the first container stopped for CHECK. The check performs its own fresh write and read while the container is unavailable.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-05-ha-control-plane/solution2.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-05-ha-control-plane/solution2.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-05-ha-control-plane/verify2.sh
```{{exec}}
