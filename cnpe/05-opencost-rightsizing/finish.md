# Costs under control! 🎉

You used real FinOps tooling the way the CNPE expects:

1. **Query OpenCost** (plugin, API, or UI) instead of eyeballing requests
2. **Act on the data** — scale up what is starved, scale down what burns money
3. **Mark your work** with labels so automation and auditors can find it

## Key facts to remember

- OpenCost = CNCF cost monitoring; allocation API on **9003**, UI on **9090**
- `kubectl cost` works against OpenCost with `--service-name opencost --service-port 9003 -N opencost --allocation-path /allocation/compute`
- Cost ≈ requests × replicas × time. Requests drive cost even at 0% usage
- "Scale up **by** N" ≠ "scale **to** N" — read the current replica count first

📖 This lab is **Chapter 5** of the *CNPE Scenarios and Solutions* book.

Next lab: **06 — GitOps-install podinfo with Argo CD**.
