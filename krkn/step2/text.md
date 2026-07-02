# Step 2: Your First Chaos Experiment - Kill Pods

Time to run your first chaos scenario. Krkn's **pod-scenarios** picks pods matching a label, deletes them, and then verifies replacements come back within a recovery timeout.

## Make Sure Setup Finished

The background setup pre-pulls the scenario image (it's large). This command waits until everything is in place:

```bash
until [ -f /tmp/.krkn-setup-done ]; do echo "waiting for background setup..."; sleep 5; done
echo "krknctl $(krknctl --version 2>/dev/null | head -1) ready, scenario images pulled."
```{{exec}}

> **Note:** krknctl may mention that a newer version is available - ignore that during this tutorial. We intentionally pin a version to avoid a known kubeconfig-permissions bug in the latest beta ([krknctl#95](https://github.com/krkn-chaos/krknctl/issues/95)).
>
> Also: krknctl fetches scenario metadata from quay.io on each run. If that request hiccups you may see a Go panic mentioning `getRegistryImages` - a known upstream bug. This environment retries automatically; if you ever hit it elsewhere, just re-run the command.

## Take a "Before" Snapshot

Note the pod **names** and **ages** - you'll compare them after the chaos:

```bash
kubectl get pods -n demo
kubectl get pods -n demo -o name > /tmp/pods-before.txt
```{{exec}}

## Where Does the Chaos Actually Run?

One thing that surprises people: `krknctl` does **not** deploy anything into your cluster to inject this chaos. It runs the scenario as a **local container** (via Podman here - Docker works too) right on this machine, and that container talks to the Kubernetes API using your kubeconfig - just like `kubectl` does. Your cluster's own runtime (containerd) is not involved at all.

```
  krknctl ──> podman ──> [krkn-hub scenario container] ──kubeconfig──> Kubernetes API
```

This is what makes Krkn drop-in for CI/CD: any runner that can start a container can chaos-test any cluster it can reach.

## Unleash the Kraken

Run the pod disruption scenario against the `demo` namespace, targeting the `app=nginx` label, killing **1 pod**:

```bash
krknctl run pod-scenarios \
  --namespace demo \
  --pod-label "app=nginx" \
  --disruption-count 1 \
  --expected-recovery-time 120
```{{exec}}

While it runs, here is what Krkn is doing under the hood:

1. **Discovers** pods in `demo` matching `app=nginx`
2. **Selects** 1 of them (randomly) and deletes it
3. **Waits** for the pod to actually terminate (kill timeout)
4. **Verifies** the deployment gets back to full strength within `--expected-recovery-time` (120s)
5. **Reports** success or failure via the container exit code

The run takes a minute or two - watch the log output streaming from the scenario container.

## Compare: What Changed?

```bash
kubectl get pods -n demo
echo "--- pods before the chaos ---"
cat /tmp/pods-before.txt
```{{exec}}

You should see that one pod has a **new name and a much younger age** - Kubernetes' ReplicaSet controller noticed the missing pod and immediately created a replacement. Your deployment survived its first chaos experiment.

> **This is the core chaos engineering loop**: inject a failure, then *prove* the system healed - instead of assuming it would.
