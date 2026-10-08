# Drain, recover workloads and uncordon

Delete the exercise's bare Pods `cka20/probe` and `cka23/blocked`. Drain `node01` with `--ignore-daemonsets`; the `resident` Deployment must move to the other eligible node and remain available. Review any refusal instead of using `--force`. Uncordon `node01`, then create `cka23/restored` with `busybox:1.37.0`, `sleep 3600`, and a nodeSelector for `node01`. Prove the fresh Pod starts there and the original Deployment Pod was replaced.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-04-worker-operations/solution3.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-04-worker-operations/solution3.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-04-worker-operations/verify3.sh
```{{exec}}
