# Alpha: gang scheduling with the Workload API

This is the headline of 1.37's scheduling work. **Workload-Aware Scheduling** gives the
scheduler a first-class notion of "these Pods belong together". In 1.37 the core types
`Workload` and `PodGroup` were promoted to **`scheduling.k8s.io/v1beta1`**, and the old
`GangScheduling` / `WorkloadAwarePreemption` gates were removed in favour of a single
**`GenericWorkload`** gate (Beta, still off by default). Turning that gate on also
auto-enables the `GangScheduling` scheduler plugin - you do not need a custom
KubeSchedulerConfiguration.

Why you care: an ML training job with 8 workers is useless with 5 of them scheduled.
Partial placement burns capacity and deadlocks against other jobs. Gang scheduling makes
placement **all-or-nothing**.

## First, the problem

To make this deterministic on a single node, each Deployment below uses pod anti-affinity
on `kubernetes.io/hostname`, so **at most one of its Pods can ever be scheduled here**.

Three replicas, no PodGroup - the default scheduler:

```plain
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: plain-workers
spec:
  replicas: 3
  selector:
    matchLabels: {app: plain-workers}
  template:
    metadata:
      labels: {app: plain-workers}
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels: {app: plain-workers}
            topologyKey: kubernetes.io/hostname
      containers:
      - name: worker
        image: registry.k8s.io/pause:3.10.2
EOF
```{{exec}}

```plain
kubectl get pods -l app=plain-workers
```{{exec}}

**One Running, two Pending.** The scheduler happily placed a partial set - that lone Pod is
now holding a slot while the job it belongs to can never start.

## Now the gang

Create a standalone PodGroup with a gang policy. `minCount` is the number of Pods that must
be placeable *at the same time* for the scheduler to admit any of them:

```plain
cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1beta1
kind: PodGroup
metadata:
  name: gang-workers
spec:
  schedulingPolicy:
    gang:
      minCount: 3
EOF
```{{exec}}

Point Pods at it with the new `spec.schedulingGroup` field:

```plain
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gang-workers
spec:
  replicas: 3
  selector:
    matchLabels: {app: gang-workers}
  template:
    metadata:
      labels: {app: gang-workers}
    spec:
      schedulingGroup:
        podGroupName: gang-workers
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels: {app: gang-workers}
            topologyKey: kubernetes.io/hostname
      containers:
      - name: worker
        image: registry.k8s.io/pause:3.10.2
EOF
```{{exec}}

```plain
kubectl get pods -l app=gang-workers
```{{exec}}

**Zero Running, three Pending.** The scheduler evaluated the group, saw it could not place
3 at once, and placed *none*. No capacity wasted on a doomed partial set.

Look at what the PodGroup reports:

```plain
kubectl get podgroup gang-workers -o yaml
```{{exec}}

```plain
kubectl describe podgroup gang-workers
```{{exec}}

The `PodGroupInitiallyScheduled` condition (renamed from `PodGroupScheduled` in 1.37) only
flips once the group is admitted for the first time.

## Make it fit

`minCount` is **mutable** in 1.37 to support scaling. Drop the anti-affinity instead and
watch a gang that fits get admitted as a unit:

```plain
cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1beta1
kind: PodGroup
metadata:
  name: gang-fits
spec:
  schedulingPolicy:
    gang:
      minCount: 3
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gang-fits
spec:
  replicas: 3
  selector:
    matchLabels: {app: gang-fits}
  template:
    metadata:
      labels: {app: gang-fits}
    spec:
      schedulingGroup:
        podGroupName: gang-fits
      containers:
      - name: worker
        image: registry.k8s.io/pause:3.10.2
        resources:
          requests: {cpu: 5m, memory: 8Mi}
EOF
```{{exec}}

```plain
kubectl get pods -l app=gang-fits
```{{exec}}

All three, together.

```plain
kubectl get podgroups
```{{exec}}

## Clean up

```plain
kubectl delete deploy plain-workers gang-workers gang-fits --ignore-not-found
kubectl delete podgroup gang-workers gang-fits --ignore-not-found
```{{exec}}

> Also new in 1.37 and enabled here: **`CompositePodGroup`** (`scheduling.k8s.io/v1alpha3`)
> for nesting groups into a hierarchy, and **`PodGroupPreemptionPolicy`** for controlling
> how a PodGroup is preempted. Try `kubectl explain compositepodgroup.spec` and
> `kubectl explain podgroup.spec.preemptionPolicy`.
