# Blue/Green Release with a Manual Promotion Gate

**Domain:** GitOps and Continuous Delivery &nbsp;|&nbsp; **Suggested time:** 12 minutes

The `catalog` service in `shop-core` must move to **blue/green** releases. QA insists on
a **human decision** before customers see a new version.

Already in the namespace (do not delete until told):

- Deployment **`catalog`** — image `nginx:1.25` (the "blue" build), 2 replicas
- Service **`catalog-active`** — what customers hit
- Service **`catalog-preview`** — what QA hits

**Your task:**

1. Create a **Rollout** named **`catalog`** (blueGreen strategy, 2 replicas,
   same `app: catalog` template, image `nginx:1.25`) with:
   - `activeService: catalog-active`, `previewService: catalog-preview`
   - **No auto-promotion** — a human promotes
2. Release image **`nginx:1.26`** (the "green" build), check it on the preview
   Service, then **promote** it to active
3. Only after the Rollout owns traffic, scale the old Deployment to **0**

Click **START** when ready.
