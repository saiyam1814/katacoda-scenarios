# Metrics-driven canary shipped! 🎉

Flagger walked the weights, watched the success rate, and promoted on its own - 
and it would have rolled back on its own too.

## Key facts to remember

- **Flagger generates** the primary Deployment, the Services, and the VirtualService
  from one `Canary` resource - Argo Rollouts expects you to bring them
- Your original Deployment becomes the *template*; `-primary` serves the traffic - 
  do not panic when `media-proxy` shows 0/0 replicas, that is the design
- `analysis`: `interval` (how often), `stepWeight`/`maxWeight` (how far),
  `threshold` (failed checks before rollback), metrics (the judge)
- `request-success-rate` and `request-duration` are built-ins for istio/linkerd
  providers - reach for them before writing PromQL
- Trigger = any change to the target Deployment's pod spec (image, env, …)
- Rollout vs Flagger in one line: **Rollouts executes your plan; Flagger enforces
  your SLO**

📖 This lab is **Chapter 26** (bonus) of the *CNPE Scenarios and Solutions* book.

Next lab: **27 - mTLS-identity authorization with Linkerd**.
