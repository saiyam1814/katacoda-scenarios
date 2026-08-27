# Kubernetes 1.37 hands-on - video script

**Target length:** 9 to 11 minutes
**Format:** screen recording of the Killercoda terminal, talking head optional
**Scenario:** https://killercoda.com/saiyampathak/scenario/kube137
**Expected outputs:** see `TRANSCRIPT.md` (all captured from a real 1.37.0 run)
**Animations:** `animations.html` - four looping SVG scenes to cut in

> Before recording: open the scenario, let the intro script finish, and confirm you see
> `Kubernetes v1.37.0 is up with these alpha/beta gates on:`. If it says
> `(plain - alpha gates were NOT applied)`, restart the environment.

---

## 0:00 - 0:40 | Cold open

> "Kubernetes 1.37 shipped on the 26th of August. Most release videos read you the changelog.
> I want to do something different: actually turn the alpha features on and run them, because
> the interesting part of 1.37 is not any single feature. It is that turning alpha features on
> got noticeably harder, in a good way."

Show the terminal with the cluster already up.

> "This is a single node 1.37 cluster on Killercoda, no install, no cloud account. And it comes
> up with nine alpha and beta gates already switched on. Link in the description, it is free."

**[CUT TO ANIMATION 1: the four rules]** - hold about 8 seconds.

---

## 0:40 - 1:40 | Step 1: prove it is 1.37, and one thing that is just nice

```
kubectl get nodes
kubectl version | head -2
```

> "v1.37.0. Now, one small quality of life thing before the deep end."

```
kubectl get svc kubernetes -o kyaml
```

> "kyaml went stable in 1.37. Look at the output: every string is quoted, lists are in flow
> style. If you have ever been bitten by a YAML file where `no` became `false`, or a version
> string `1.10` became the number one point one, this is the fix. It is a YAML dialect that is
> still valid YAML, but unambiguous."

---

## 1:40 - 3:10 | Step 2: the rules for turning alphas on

> "Here is the thing people get wrong. Turning on an alpha feature is not one switch."

```
cat /root/alpha/kubeadm-alpha.yaml
```

> "Rule one: the gate goes on every component that participates. Apiserver, controller manager,
> scheduler, and the kubelet. Note where they go: each component's extraArgs. Not
> ClusterConfiguration.featureGates - that field is for kubeadm's own gates, and that trips up
> a lot of people."

```
kubectl api-resources --api-group=scheduling.k8s.io
```

> "Rule two: if the feature ships new API types, the gate is not enough. You also need
> runtime-config to actually serve the group version. Miss that and kubectl just says
> `no matches for kind`, with the gate on, and you will lose twenty minutes."

**[CUT TO ANIMATION 2: gate plus runtime-config]** - hold about 10 seconds.

> "And rule three is new in 1.37, and it is the one that got me. Gates now declare
> dependencies on other gates, and the check is fatal."

Show the error from `TRANSCRIPT.md`:

```
command failed ... enabled, but depends on features that are disabled:
[TopologyAwareWorkloadScheduling]
```

> "CompositePodGroup requires TopologyAwareWorkloadScheduling. I did not know that when I built
> this scenario, and my apiserver simply refused to boot. Which honestly is the right call:
> better a loud failure at startup than a feature that half works."

**[CUT TO ANIMATION 3: dependency chain]** - hold about 8 seconds.

---

## 3:10 - 5:30 | Step 3: gang scheduling (the main event)

> "Now the headline. Workload aware scheduling. In 1.37, Workload and PodGroup got promoted to
> scheduling.k8s.io/v1beta1, and the old GangScheduling and WorkloadAwarePreemption gates were
> collapsed into a single gate, GenericWorkload."

> "The problem it solves: you have a training job with three workers. Two get scheduled, one
> does not. Those two are now sitting on GPUs doing nothing, blocking everyone else, waiting
> for a third that may never come. That is not a hypothetical, that is Tuesday."

Apply `plain-workers` (three replicas, anti-affinity so only one fits):

```
kubectl get pods -l app=plain-workers
```

> "One Running, two Pending. Classic partial placement. That one Pod is burning a slot for a
> job that cannot start."

**[CUT TO ANIMATION 4: partial vs all-or-nothing]** - hold about 12 seconds.

Now the PodGroup:

```
kubectl apply -f -   # PodGroup with gang.minCount: 3
```

> "Three lines. A PodGroup with a gang policy and a minCount of three. Pods join it with a new
> field in the Pod spec: spec.schedulingGroup.podGroupName."

Apply `gang-workers`, then:

```
kubectl get pods -l app=gang-workers
```

> "Zero Running. Three Pending. The scheduler evaluated the whole group, worked out it could
> not place three at once, and placed none of them. All or nothing. No wasted capacity."

```
kubectl describe podgroup gang-workers
```

> "And the PodGroup itself carries the state. That condition used to be called
> PodGroupScheduled; in 1.37 it is PodGroupInitiallyScheduled, because it only tells you the
> group was admitted once, not that it is healthy right now."

---

## 5:30 - 7:30 | Step 4: small things, and a good failure

```
kubectl exec volume-alpha -- stat -c '%a %n' /data/strict /data/normal
```

> "emptyDir.mode. Before 1.37 an emptyDir was always 0777 and your only lever was fsGroup. Now
> you just say what you want. 700 on the one I asked for, 777 on the default."

```
kubectl exec volume-alpha -- stat -c '%u %a %n' /etc/app/greeting
```

> "And defaultUser. ConfigMap, Secret and projected volumes are written atomically by the
> kubelet, and those files were always owned by root. Now they are owned by UID 1000. That is
> what lets a non-root container read a Secret without you granting world-read on it."

> "Now the third one, and this is my favourite part of the whole scenario because it failed."

Apply the `bindMountOptions` Pod, then:

```
kubectl get pod volume-strict
kubectl describe pod volume-strict | tail -4
```

> "Accepted by the apiserver. Never scheduled. `node(s) didn't match Pod's required features`."

```
kubectl get node -o jsonpath='{.items[0].status.declaredFeatures}'
containerd --version
```

> "This is NodeDeclaredFeatures, which went GA in 1.37. The kubelet publishes what the node can
> actually honour, and the scheduler will not place a Pod that needs something missing.
> bindMountOptions needs the container runtime to advertise MountOptions over CRI, and
> containerd 2.2.1 does not yet. So the gate is on everywhere and it still does not work."

> "Here is why I left it in. Before 1.37, that Pod would have started, mounted the volume
> without noexec, and told you nothing. You would have shipped it thinking your scratch
> directory was hardened. Now you get a scheduling event that names the problem. That is a
> genuinely better failure, and it is the kind of thing you only find by running the release
> instead of reading about it."

---

## 7:30 - 9:00 | Step 5: StatefulSet Recreate

```
kubectl rollout status statefulset/web
```

> "First, a gotcha. rollout status only supports RollingUpdate, so it errors out. Wait on the
> Pods instead."

```
kubectl set image statefulset/web web=nginx:1.28-alpine
# sampling loop from TRANSCRIPT.md
```

> "Watch the timestamps. At t plus one, web-0 is terminating. At t plus two, all three are
> down. Then they come back. Deployments have had Recreate forever; StatefulSets only get it
> now, in alpha. You want this when old and new genuinely cannot coexist: a schema migration,
> a single writer lock, a leader election that hates split versions."

```
kubectl get statefulset web -o jsonpath='{.status.conditions}'
```

> "RecreateCompleted. All pods recreated successfully."

---

## 9:00 - 9:45 | Close

> "So, four things I would take away from 1.37. Gang scheduling is real and it is in beta.
> Feature gates now have dependencies, and they will refuse to boot rather than half work.
> Nodes now declare what they can do, and the scheduler respects it. And kyaml is stable, which
> is a small thing you will use every single day."

> "Everything I just ran is a free Killercoda scenario, link below. It builds the cluster with
> the gates already on, and there is a helper script on the box for flipping any other gate and
> rolling it back when you break something. Which you will. That is the point."

> "One warning: do not reach for AllAlpha equals true. Enable the handful you actually want."

---

## Recording notes

- Resize the terminal font up. The gate strings are long and wrap badly at small sizes.
- The setup takes 3 to 4 minutes. Record it separately and time-lapse it, or start after.
- Step 3 needs about 20 seconds after apply before Pending states settle. Cut the wait.
- `busybox:1.36` and `nginx:1.29-alpine` pull on first use. Pre-pull before recording:
  `crictl pull busybox:1.36` is unavailable, so just run step 4 and step 5 once as a warm-up
  and reset with `kubectl delete` before the real take.
- If anything wedges: `/root/alpha/gate.sh restore` puts the control plane back.
