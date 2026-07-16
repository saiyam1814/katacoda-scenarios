# Incident resolved! 🎉

Three failures, zero Deployment edits. You fixed the *environment around* the workloads
— which is exactly what platform engineers own.

## The triage sweep to memorize

```
kubectl -n <ns> get deploy,pods            # what is unhappy?
kubectl -n <ns> get events --sort-by=.lastTimestamp | tail   # why?
kubectl -n <ns> describe pod <sad-pod>     # details
kubectl -n <ns> get quota,limitrange,secret,pvc,sa           # environment
```

## Failure signatures → fixes

| Signature | Meaning | Allowed fix |
|---|---|---|
| Deploy 0/1, **no pod at all** | quota blocks creation | raise ResourceQuota |
| `CreateContainerConfigError` | missing Secret/ConfigMap ref | create it — kubelet self-heals |
| `Pending` + `claim not found` | missing PVC | create the PVC |

- `metadata.generation` of a Deployment increments on **any** spec edit — graders can
  (and do) check you never touched it
- Pod deletion is almost always allowed; deployment mutation almost never

📖 This lab is **Chapter 19** of the *CNPE Scenarios and Solutions* book.

Next lab: **20 — Give a CI bot least-privilege RBAC**.
