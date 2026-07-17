# Cap Pods and CPU Defaults for squad-nebula

**Domain:** Platform Architecture and Infrastructure &nbsp;|&nbsp; **Suggested time:** 8 minutes

The `squad-nebula` team shares a cluster with other squads. Last week they accidentally
scheduled 40 Pods and starved everyone else. The platform team has asked you to add
guardrails to their namespace:

- **ResourceQuota** `nebula-pod-cap` - the namespace may never run more than **6 Pods**
- **LimitRange** `nebula-cpu-defaults` - containers that do not declare CPU get a
  **default request and limit of `50m`**, and nobody may request more than **`250m` CPU**

**Constraints (read carefully - the exam always has them):**

- Create **exactly one** ResourceQuota and **exactly one** LimitRange in `squad-nebula`
- Do **not** edit the existing `nebula-api` Deployment

Click **START** when the environment is ready.
