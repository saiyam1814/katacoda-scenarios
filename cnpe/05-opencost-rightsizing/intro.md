# Right-size Three Services with OpenCost

**Domain:** Platform Architecture and Infrastructure &nbsp;|&nbsp; **Suggested time:** 12 minutes

Finance wants the platform bill down. Three internal services run in namespaces
`alpha-svc`, `beta-svc` and `gamma-svc`. **OpenCost** is installed (namespace `opencost`)
with Prometheus behind it.

Using **only OpenCost data** (no guessing from requests):

1. Identify the **cheapest** and the **most expensive** Deployment
2. Write your findings to two files:
   - `/root/cheapest.txt` — name of the cheapest Deployment
   - `/root/expensive.txt` — name of the most expensive Deployment
3. Scale the **cheapest** Deployment **up by 2 replicas** (it is under-provisioned)
4. Scale the **most expensive** Deployment **down to exactly 2 replicas**
5. Label **both** Deployments `cost.platform.io/adjusted=yes`

**Constraint:** do not touch the third Deployment in any way.

Click **START** — the metrics pipeline takes a couple of minutes to install.
