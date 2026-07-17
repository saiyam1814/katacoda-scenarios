# Nice work! 🎉

You gave `squad-nebula` real guardrails:

- **ResourceQuota** caps *how many* objects (or how much total CPU/memory) a namespace can consume
- **LimitRange** shapes *each container*: injects defaults and enforces per-container min/max

## Exam habits you just practiced

- Generate what you can (`kubectl create quota`), write YAML only when you must
- Re-read constraints: *exactly one* of each object, *don't touch* the Deployment
- Verify the end state - graders only score what is running

## Learn the concepts

📖 This lab is **Chapter 1** of the *CNPE Scenarios and Solutions* book, which covers
namespace multi-tenancy, quota scopes, and LimitRange edge cases in depth.

Next lab: **02 - Create pg-storage and cdn-cache PVCs**.
