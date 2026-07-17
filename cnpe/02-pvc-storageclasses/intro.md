# Create pg-storage and cdn-cache PVCs

**Domain:** Platform Architecture and Infrastructure &nbsp;|&nbsp; **Suggested time:** 8 minutes

Two Deployments were just rolled out to the `storage-lab` namespace and both are stuck.
They reference PersistentVolumeClaims that nobody created:

- `pg` (Postgres) needs claim **`pg-storage`** - the DBA asked for the **high-IOPS** storage tier
- `cdn` (static content) needs claim **`cdn-cache`** - the **standard** tier is fine

Create both PVCs with:

- **512Mi** requested storage
- Access mode **ReadWriteOnce**
- The most appropriate **existing** StorageClass for each

**Constraints:**

- Do **not** edit the Deployments
- Do **not** create or modify StorageClasses - pick from what the cluster offers

Click **START** when the environment is ready.
