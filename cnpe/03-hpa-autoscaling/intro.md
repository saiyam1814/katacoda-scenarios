# Autoscale a Frontend with HorizontalPodAutoscaler

**Domain:** Platform Architecture and Infrastructure &nbsp;|&nbsp; **Suggested time:** 7 minutes

Black Friday is coming. The `storefront` Deployment in namespace `edge-web` must scale
automatically with CPU load. `metrics-server` is installed and healthy.

Create a HorizontalPodAutoscaler named **`storefront`** that:

- Targets Deployment **`storefront`**
- Runs at least **2** and at most **8** replicas
- Scales on **average CPU utilization of 60%**

Then verify the HPA can actually **read live metrics** — an HPA that shows
`<unknown>` targets would score zero on the exam even though the object exists.

Click **START** when the environment is ready.
