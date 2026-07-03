# Step 4: Drive Chaos from the Web Dashboard

Everything you've done with `kubectl` so far, Chaos Mesh can also do through a full **web dashboard** - create experiments with a form, watch their timelines, and archive results. For many teams this is how non-platform engineers run game days.

## Expose the Dashboard

The dashboard runs as a Service on port 2333 inside the cluster. Forward it to this machine:

```bash
kubectl port-forward svc/chaos-dashboard -n chaos-mesh --address 0.0.0.0 2333:2333 > /dev/null 2>&1 &
sleep 2
curl -s -o /dev/null -w "dashboard HTTP status: %{http_code}\n" http://localhost:2333
```{{exec}}

Now open it in your browser:

**[Open the Chaos Mesh Dashboard]({{TRAFFIC_HOST1_2333}})**

> We installed with `dashboard.securityMode=false`, so no login token is needed here. In production you'd keep security on and generate per-team RBAC tokens (the dashboard has a built-in generator under **Settings**).

## Explore What You've Already Done

In the dashboard:

1. Go to **Experiments** - you may see your earlier `kill-one-nginx` and `nginx-delay` experiments under **Archives** (deleted experiments are archived, not lost - another benefit of the audit trail)
2. Go to **Events** to see the injection/recovery timeline Chaos Mesh recorded

## Create an Experiment from the UI

Try creating one visually:

1. Click **New experiment**
2. Choose **Kubernetes** → **Pod Fault** → **Pod Failure**
3. Scope it: namespace `demo`, label selector `app: nginx`
4. Set **Mode** to `One`, **Duration** to `30s`
5. Name it `ui-pod-failure` and submit

Then watch from the terminal - the UI created the exact same kind of CRD you wrote by hand:

```bash
kubectl get podchaos -n demo -w
```{{exec interrupt}}

Press `Ctrl+C` after you see the experiment. `pod-failure` (unlike `pod-kill`) makes the pod *unavailable* for the duration by swapping its image for a pause image - watch the pod's READY column flip during the 30s:

```bash
kubectl get pods -n demo -l app=nginx
```{{exec}}

> **UI or YAML - same engine.** The dashboard is just another client writing the same CRDs. Teams typically prototype experiments in the UI, then export the YAML into git for repeatable pipeline runs.
