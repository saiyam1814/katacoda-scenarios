# Protect kubelet authentication and authorization

First prepare the deliberately insecure worker fixture:

```bash
bash /opt/book-labs/infra-04-worker-operations/prepare4.sh
```{{exec}}

On `node01`, disable anonymous kubelet authentication, enable webhook token authentication, set authorization mode `Webhook`, and set read-only port to zero in `/var/lib/kubelet/config.yaml`. Preserve all other configuration and restart kubelet. Anonymous `/pods` on port 10250 must return 401 and port 10255 must close. Authenticated API logs and exec for `cka23/restored` must still work. An unauthenticated API request must not list Secrets.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-04-worker-operations/solution4.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-04-worker-operations/solution4.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-04-worker-operations/verify4.sh
```{{exec}}
