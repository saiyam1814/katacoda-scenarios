# Automated Canary Analysis with Flagger

**Domain:** GitOps and Continuous Delivery (bonus lab) &nbsp;|&nbsp; **Suggested time:** 14 minutes

In lab 07 *you* programmed the canary steps with Argo Rollouts. **Flagger** flips the
model: you declare the analysis, and Flagger shifts traffic **only while live metrics
stay healthy** — a bad release rolls back on its own.

Flagger runs in `istio-system` (provider: istio, metrics from the addon Prometheus).
Namespace `release-bay` has Deployment **`media-proxy`** (nginx:1.25, 2 replicas) and
a `traffic-gen` Pod keeping requests flowing through the mesh.

**Your task:**

1. Create a **Canary** resource named **`media-proxy`** in `release-bay`:
   - `targetRef` → the `media-proxy` Deployment
   - `progressDeadlineSeconds: 300`, service port **80**
   - Analysis: `interval: 20s`, `threshold: 3`, `stepWeight: 20`, `maxWeight: 100`
   - Metric: built-in **`request-success-rate`** must stay **≥ 99%** (interval 1m)
2. Wait for Flagger to **initialize** the canary (it generates the primary Deployment
   and the Services/VirtualService for you)
3. Release **`nginx:1.26`** by updating the Deployment image and watch Flagger walk
   the weights and **promote automatically**

Click **START** while the mesh installs.
