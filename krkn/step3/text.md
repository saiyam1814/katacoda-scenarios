# Step 3: Read the Results - Recovery and Exit Codes

A chaos experiment is only useful if you can act on its result. Krkn is built for CI/CD: every run ends with an **exit code** your pipeline can gate on.

| Exit code | Meaning |
|-----------|--------------------------------------------|
| `0` | Chaos injected AND the system recovered |
| `1` | A scenario failed (e.g. no recovery in time) |
| `2` | Critical alerts fired during the run |
| `3+` | Cluster health checks failed |

## Query Your Last Run

Every `krknctl run` leaves a scenario container behind. List them and query the status of your Step 2 run:

```bash
podman ps -a --filter "name=krknctl" --format "table {{.Names}}\t{{.Status}}"
```{{exec}}

```bash
LAST_RUN=$(podman ps -a --filter "name=krknctl" --format "{{.Names}}" | head -1)
krknctl query-status "$LAST_RUN"
```{{exec}}

Your Step 2 run should report success - the nginx deployment healed, so Krkn exited `0`.

## Now Watch Chaos Find a Real Weakness

Self-healing worked because a **Deployment** manages our pods. But what about a *naked pod* - one created without any controller? You've probably seen these in real clusters...

```bash
kubectl run standalone --image=nginx -n demo --labels="app=standalone"
kubectl wait --for=condition=ready pod/standalone -n demo --timeout=60s
```{{exec}}

Attack it:

```bash
krknctl run pod-scenarios \
  --namespace demo \
  --pod-label "app=standalone" \
  --disruption-count 1 \
  --expected-recovery-time 45 || echo '>>> CHAOS EXPERIMENT FAILED - and that is the point <<<'
```{{exec}}

## What Happened?

```bash
kubectl get pods -n demo
```{{exec}}

The `standalone` pod is **gone and never came back** - no controller existed to recreate it. Krkn flagged the failed recovery.

> **This is chaos engineering paying off**: you just discovered a workload that does NOT survive failure - in a test environment, not during an outage. In a real pipeline, this non-zero exit code would block the deploy.

## Explore the Scenario Catalog

pod-scenarios is just one of many. Browse what else Krkn can do:

```bash
krknctl list available
```{{exec}}

Get details on any scenario, including every flag it supports:

```bash
krknctl describe node-cpu-hog
```{{exec}}

That's the one we run next.
