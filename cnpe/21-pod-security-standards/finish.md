# Fleet audited! 🎉

You rolled out Pod Security Standards the responsible way: **warn first, measure,
then decide** — and you didn't quietly "fix" workloads that weren't yours to change.

## Key facts to remember

- PSA = namespace labels: `pod-security.kubernetes.io/<enforce|warn|audit>=<privileged|baseline|restricted>`
- Warnings fire at **admission** — restart or server-side dry-run to see them
- `kubectl apply --dry-run=server` shows PSA warnings **without touching anything** —
  a killer exam trick
- **baseline** blocks host access (hostPath, hostNetwork, privileged);
  **restricted** additionally demands non-root, seccomp, dropped capabilities
- The `-version=latest` label pins which policy version evaluates — set it when asked

📖 This lab is **Chapter 21** of the *CNPE Scenarios and Solutions* book.

Next lab: **22 — Reject floating image tags with Gatekeeper**.
