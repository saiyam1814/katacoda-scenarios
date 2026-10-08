# Recover the stopped kubelet

`node01` has stopped reporting Ready. Find the cause using `ssh node01`, systemd and runtime evidence. Restore its kubelet. Save the cause and action in `/tmp/cka20-root-cause.txt`. Create namespace `cka20`, then Pod `probe` using `busybox:1.37.0`, command `sleep 3600`, constrained through a nodeSelector to `node01`. Verify it starts and can execute a command.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-04-worker-operations/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-04-worker-operations/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-04-worker-operations/verify1.sh
```{{exec}}
