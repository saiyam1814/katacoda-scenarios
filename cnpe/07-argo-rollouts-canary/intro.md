# Roll out media-proxy with a Weighted Canary

**Domain:** GitOps and Continuous Delivery &nbsp;|&nbsp; **Suggested time:** 14 minutes

The `media-proxy` service burned the team twice with bad releases. From now on it ships
as a **weighted canary**: 20% of traffic, then 40%, then 100%.

Namespace `release-bay` already contains (do **not** hand-edit any of them):

- Deployment **`media-proxy`** (nginx 1.25)
- Services **`media-proxy`**, **`media-proxy-stable`**, **`media-proxy-canary`**
- Istio **VirtualService `media-proxy`** with an HTTP route named **`primary`**
- A `traffic-gen` Pod continuously curling the service (so you can watch the split)

**Your task:** create an Argo Rollouts **Rollout** named **`media-proxy`** that:

- Runs **3 replicas** with the same `app: media-proxy` pod template
- Uses **canary** strategy with `media-proxy-stable` / `media-proxy-canary` services
- Routes traffic through **Istio** using VirtualService `media-proxy`, route `primary`
- Steps: **20% → pause 30s → 40% → pause 30s → 100%**

Then release **nginx:1.26** through it and watch the weights move.

Click **START** while Istio and Argo Rollouts install.
