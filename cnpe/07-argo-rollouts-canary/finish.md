# Canary shipped! 🎉

You just ran the exact progressive-delivery loop the CNPE loves: Rollout + Istio
traffic splitting + weighted steps, with your own eyes on the live traffic mix.

## Key facts to remember

- Rollout ≈ Deployment + `strategy.canary` / `strategy.blueGreen`
- **Istio mode**: Argo Rollouts edits the **VirtualService route weights** for you - 
  never patch them by hand mid-rollout
- `pause: {duration: Ns}` auto-advances; bare `pause: {}` waits for a human `promote`
- First revision of a new Rollout skips canary steps (nothing old to compare against)
- The alternative tool for this task is **Flagger**: you create a `Canary` object and
  Flagger generates the primary/canary services itself - covered in the book chapter

📖 This lab is **Chapter 7** of the *CNPE Scenarios and Solutions* book.

Next lab: **08 - Blue/green with a manual promotion gate**.
