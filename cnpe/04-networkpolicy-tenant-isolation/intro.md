# Isolate a Tenant with NetworkPolicies

**Domain:** Platform Architecture and Infrastructure &nbsp;|&nbsp; **Suggested time:** 10 minutes

Security review flagged namespace `tenant-red`: any Pod in the cluster can reach its
workloads. Lock it down without breaking the edge path:

1. NetworkPolicy **`deny-all-ingress`** - deny **all ingress** to every Pod in `tenant-red`
2. NetworkPolicy **`allow-api-from-edge`** - for Pods labelled **`app=api`**:
   - allow ingress **only** from namespace `ingress-gw` (it carries label `purpose=edge`) on **TCP 8080**
   - allow **DNS egress** (UDP 53) so lookups keep working

**The cast:**

- `tenant-red` - the `api` Deployment (port 8080) + Service
- `ingress-gw` - labelled `purpose=edge`, contains Pod `edge-client`
- `other-squad` - no label, contains Pod `squad-client` (should be blocked)

Click **START** when the environment is ready.
