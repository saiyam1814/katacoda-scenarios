# Diagnose the three failures

Run the standard triage sweep - in this order, every time:

```bash
kubectl -n metrics-portal get deploy,pods
```{{exec}}

```bash
kubectl -n metrics-portal get events --sort-by=.lastTimestamp | tail -15
```{{exec}}

```bash
kubectl -n metrics-portal describe pod -l app=metrics-db 2>/dev/null | tail -8
```{{exec}}

```bash
kubectl -n metrics-portal get quota,limitrange,secret,pvc
```{{exec}}

Three distinct problems are hiding in that output. When you can name all three,
record your diagnosis (one line each) - this mirrors how you should take notes
in the exam terminal:

```bash
cat > /root/triage.txt <<'EOF'
1. quota portal-quota caps pods at 1 - blocks metrics-ui pod creation
2. secret metrics-db-auth missing - metrics-db pod in CreateContainerConfigError
3. pvc metrics-ui-data missing - metrics-ui pod would stay Pending
EOF
cat /root/triage.txt
```{{exec}}

<details><summary>✦ How each problem announces itself</summary>

- **Quota:** the Deployment shows `0/1` but **no Pod exists** - the ReplicaSet event
  says `forbidden: exceeded quota: portal-quota`
- **Missing Secret:** Pod status `CreateContainerConfigError`, describe says
  `secret "metrics-db-auth" not found`
- **Missing PVC:** the Pod (once creatable) stays `Pending`, describe says
  `persistentvolumeclaim "metrics-ui-data" not found`

</details>
