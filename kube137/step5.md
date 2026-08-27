# Alpha: StatefulSet `Recreate`, then flip a gate yourself

## StatefulSet Recreate strategy

`StatefulSetRecreateStrategy` (alpha, new in 1.37) adds a third `updateStrategy.type`
alongside `RollingUpdate` and `OnDelete`. Deployments have had `Recreate` forever; for
StatefulSets it matters when the old and new versions genuinely cannot coexist - a schema
migration, a single-writer lock, a leader election that hates split versions.

```plain
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  clusterIP: None
  selector: {app: web}
  ports: [{port: 80}]
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: web
  replicas: 3
  updateStrategy:
    type: Recreate
  selector:
    matchLabels: {app: web}
  template:
    metadata:
      labels: {app: web}
    spec:
      terminationGracePeriodSeconds: 1
      containers:
      - name: web
        image: nginx:1.29-alpine
        resources:
          requests: {cpu: 5m, memory: 16Mi}
EOF
```{{exec}}

Note that `kubectl rollout status` does **not** work here - it only supports
`RollingUpdate`, so wait on the Pods instead:

```plain
kubectl wait --for=condition=Ready pod -l app=web --timeout=240s
```{{exec}}

Now change the image. With `RollingUpdate` you would see `web-2`, then `web-1`, then `web-0`
cycle one at a time. With `Recreate`, **all three go down together first**. Sample the state
once a second so you can actually see it:

```plain
kubectl set image statefulset/web web=nginx:1.28-alpine
for i in $(seq 1 8); do
  echo "[t+${i}s] $(kubectl get pods -l app=web --no-headers | awk '{print $1"="$3}' | tr '\n' ' ')"
  sleep 1
done
```{{exec}}

```plain
[t+1s] web-0=Terminating web-1=Running web-2=Running
[t+2s] web-0=Completed web-1=Completed web-2=Completed
[t+3s] web-0=ContainerCreating
[t+7s] web-0=Running web-1=Running web-2=ContainerCreating
[t+8s] web-0=Running web-1=Running web-2=Running
```

At `t+2s` the entire set is down. That is the whole point of `Recreate`: no moment where old
and new versions are serving at the same time. The alpha gate also adds a `Progressing`
condition to StatefulSet status:

```plain
kubectl get statefulset web -o jsonpath='{.status.conditions}' | python3 -m json.tool
```{{exec}}

```plain
kubectl delete statefulset web && kubectl delete svc web
```{{exec}}

## Flip your own gate

`/root/alpha/gate.sh` patches the static Pod manifests in `/etc/kubernetes/manifests` for
kube-apiserver, kube-controller-manager and kube-scheduler, then waits for the API server to
restart. It snapshots the manifests the first time you use it.

Take an explicit backup first:

```plain
/root/alpha/gate.sh backup
```{{exec}}

Turn on `NodeLifecycleConditions` - an alpha in 1.37 that adds well-known Node lifecycle
conditions:

```plain
/root/alpha/gate.sh add NodeLifecycleConditions=true
```{{exec}}

```plain
/root/alpha/gate.sh show
```{{exec}}

```plain
kubectl describe node $(hostname -s) | sed -n '/Conditions:/,/Addresses:/p'
```{{exec}}

If a feature ships **new API types**, the gate alone is not enough - the group version has
to be served too. That is the second half of `gate.sh`:

```plain
/root/alpha/gate.sh api storage.k8s.io/v1alpha1=true
```{{exec}}

```plain
kubectl api-versions | grep alpha
```{{exec}}

### Roll it back

```plain
/root/alpha/gate.sh restore
```{{exec}}

```plain
/root/alpha/gate.sh show
```{{exec}}

### One warning

You will see `--feature-gates=AllAlpha=true` suggested around the internet. It does work,
and it is a fast way to get an unbootable control plane - it switches on gates that conflict
with each other, gates that need a driver you do not have, and gates whose defaults are
`false` precisely because they are not finished. Enable the handful you actually want to
test. If you do try it here, `gate.sh restore` is your way back.

### Don't forget the kubelet

Kubelet gates live somewhere different again - `/var/lib/kubelet/config.yaml` under
`featureGates:` - and the kubelet has to be restarted to pick them up:

```plain
grep -A 8 featureGates /var/lib/kubelet/config.yaml
```{{exec}}

`gate.sh` has a separate subcommand for those, because patching the static pod manifests
does nothing for node-side features:

```plain
/root/alpha/gate.sh kubelet DefaultPodSysctls=true
```{{exec}}

```plain
kubectl get node -o jsonpath='{.items[0].status.declaredFeatures}'; echo
```{{exec}}

Since `NodeDeclaredFeatures` is GA in 1.37, a node-side gate you forget shows up as a
`FailedScheduling` event saying the node "didn't match Pod's required features" - not as a
silently ignored field.
