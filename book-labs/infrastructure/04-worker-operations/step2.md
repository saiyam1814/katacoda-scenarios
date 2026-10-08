# Prove what cordon does

Cordon `node01`. Create Pod `blocked` in namespace `cka23`, image `nginx:1.28.0-alpine`, constrained through a nodeSelector to `node01`. Do not set `nodeName`. Show that it remains Pending with a current scheduler event, while the existing `resident` Deployment Pod keeps running there. Leave this state for CHECK.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-04-worker-operations/solution2.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-04-worker-operations/solution2.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-04-worker-operations/verify2.sh
```{{exec}}
