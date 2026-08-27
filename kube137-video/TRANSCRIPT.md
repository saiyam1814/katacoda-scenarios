# kube137 - verified commands and outputs

Every output below was captured from a live Killercoda run of
[the kube137 scenario](https://killercoda.com/saiyampathak/scenario/kube137) on
**Kubernetes v1.37.0**, 27 August 2026. Use these as the expected results when recording.

---

## Setup (runs automatically on the intro screen)

```
curl -sfL https://raw.githubusercontent.com/saiyam1814/katacoda-scenarios/main/kube137/setup.sh -o /tmp/kube137-setup.sh && bash /tmp/kube137-setup.sh
==> [0/10] Preflight
==> [1/10] Base packages
...
Kubernetes v1.37.0 is up with these alpha/beta gates on:
  GenericWorkload=true,TopologyAwareWorkloadScheduling=true,CompositePodGroup=true,PodGroupPreemptionPolicy=true,VolumeBindMountOptions=true,EmptyDirVolumeMode=true,StatefulSetRecreateStrategy=true,AtomicWriteVolumeUserFields=true,H2CContainerProbe=true
Helper: /root/alpha/gate.sh   (add | kubelet | api | show | backup | restore)
```

Takes roughly 3 to 4 minutes. **Start recording after this line appears.**

---

## Step 1 - cluster up

```
$ kubectl get nodes
NAME     STATUS   ROLES           AGE   VERSION
ubuntu   Ready    control-plane   47s   v1.37.0

$ kubectl version | head -2
Client Version: v1.37.0
Kustomize Version: v5.8.1
```

`kubectl get -o kyaml`, promoted to **stable** in 1.37:

```
$ kubectl get svc kubernetes -o kyaml
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "kubernetes",
    namespace: "default",
    ...
  },
  spec: {
    clusterIP: "10.96.0.1",
    ports: [{
      name: "https",
      port: 443,
      protocol: "TCP",
      targetPort: 6443,
    }],
    type: "ClusterIP",
  },
}
```

Every string is quoted, so `yes`, `no` and `1.10` stop being ambiguous.

---

## Step 2 - what is switched on

```
$ kubectl api-resources --api-group=scheduling.k8s.io
NAME                 SHORTNAMES   APIVERSION                    NAMESPACED   KIND
compositepodgroups                scheduling.k8s.io/v1alpha3    true         CompositePodGroup
podgroups                         scheduling.k8s.io/v1beta1     true         PodGroup
priorityclasses      pc           scheduling.k8s.io/v1          false        PriorityClass
workloads                         scheduling.k8s.io/v1beta1     true         Workload
```

```
$ kubectl get node -o jsonpath='{.items[0].status.declaredFeatures}'
["ExtendWebSocketsToKubelet","InPlacePodLevelResourcesVerticalScaling","InPlacePodVerticalScalingInitContainers","RestartAllContainersOnContainerExits"]
```

```
$ /root/alpha/gate.sh show
--- kube-apiserver
    - --feature-gates=GenericWorkload=true,TopologyAwareWorkloadScheduling=true,CompositePodGroup=true,...
    - --runtime-config=scheduling.k8s.io/v1beta1=true,scheduling.k8s.io/v1alpha3=true
--- kube-controller-manager
    - --feature-gates=GenericWorkload=true,...
--- kube-scheduler
    - --feature-gates=GenericWorkload=true,...
```

---

## Step 3 - gang scheduling (the money shot)

Both Deployments use pod anti-affinity on `kubernetes.io/hostname`, so on a single node at
most **one** Pod of each can ever be placed.

```
$ kubectl get pods -l app=plain-workers --no-headers | awk '{print $3}' | sort | uniq -c
      2 Pending
      1 Running

$ kubectl get pods -l app=gang-workers --no-headers | awk '{print $3}' | sort | uniq -c
      3 Pending
```

Without a PodGroup the scheduler places a partial set and that one Running Pod holds a slot
for a job that can never start. With `gang.minCount: 3` it places **none**.

---

## Step 4 - volume alphas

```
$ kubectl exec volume-alpha -- stat -c '%a %n' /data/strict /data/normal
700 /data/strict
777 /data/normal

$ kubectl exec volume-alpha -- stat -c '%u %a %n' /etc/app/greeting
1000 777 /etc/app/greeting
```

`bindMountOptions` is accepted by the apiserver but never scheduled:

```
$ kubectl get pod volume-strict
NAME            READY   STATUS    RESTARTS   AGE
volume-strict   0/1     Pending   0          20s

$ kubectl describe pod volume-strict | tail -4
  Warning  FailedScheduling  67s  default-scheduler  0/1 nodes are available:
  1 node(s) didn't match Pod's required features. preemption: 0/1 nodes are available:
  1 Preemption is not helpful for scheduling.

$ containerd --version
containerd github.com/containerd/containerd/v2 2.2.1
```

The node never declares `VolumeBindMountOptions` because the feature requires a CRI runtime
that advertises `MountOptions`, which containerd 2.2.1 does not.

---

## Step 5 - StatefulSet Recreate

`kubectl rollout status` does not support `Recreate`:

```
$ kubectl rollout status statefulset/web
error: rollout status is only available for RollingUpdate strategy type
```

Use the sampling loop instead. This is the clip to record:

```
$ kubectl set image statefulset/web web=nginx:1.28-alpine
statefulset.apps/web image updated
[t+1s] web-0=Terminating web-1=Running web-2=Running
[t+2s] web-0=Completed web-1=Completed web-2=Completed
[t+3s] web-0=ContainerCreating
[t+4s] web-0=ContainerCreating
[t+5s] web-0=ContainerCreating
[t+6s] web-0=ContainerCreating
[t+7s] web-0=Running web-1=Running web-2=ContainerCreating
[t+8s] web-0=Running web-1=Running web-2=Running
```

```
$ kubectl get statefulset web -o jsonpath='{.status.conditions}'
[{"lastTransitionTime":"2026-08-27T05:29:32Z","message":"All pods recreated successfully",
  "reason":"RecreateCompleted","status":"False","type":"Progressing"}]
```

---

## The failure that is worth showing

If you want to demo the gate dependency rule live, add `CompositePodGroup` without
`TopologyAwareWorkloadScheduling` and read the apiserver log:

```
$ tail -n 25 $(ls -t /var/log/pods/kube-system_kube-apiserver*/kube-apiserver/*.log | head -1)
run.go:72] "command failed" err="...enabled, but depends on features that are disabled:
[TopologyAwareWorkloadScheduling]"
```

Recover with `/root/alpha/gate.sh restore`.
