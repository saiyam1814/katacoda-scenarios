# Autoscaling mastered! 🎉

You created an HPA the exam way *and* watched a real scale event.

## Key facts to remember

- **CPU utilization % = usage ÷ container requests.** No requests → `<unknown>` → no scaling
- `kubectl autoscale deploy <name> --cpu-percent --min --max` is the fastest correct answer
- `<unknown>` targets almost always mean: metrics-server broken/missing, or requests missing
- Scale-up is fast; scale-down waits ~5 minutes by design
- The modern API is `autoscaling/v2` — memory, custom and external metrics live there too

📖 This lab is **Chapter 3** of the *CNPE Scenarios and Solutions* book.

Next lab: **04 — Isolate a tenant with NetworkPolicies**.
