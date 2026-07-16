# Promoted like a pro! 🎉

You ran a full blue/green cycle: preview lane, human gate, instant switchover,
safe rollback window.

## Key facts to remember

- `autoPromotionEnabled: false` **is** the manual gate — memorize this field
- Promotion = selector flip on the active Service; instant, no restarts
- The previous ReplicaSet stays up for `scaleDownDelaySeconds` (default 30s) — that is
  your `undo` window
- `kubectl argo rollouts promote <name>` / `undo <name>` are the two verbs to know
- Blue/green needs 2× capacity during the transition — quota-capped namespaces bite here

📖 This lab is **Chapter 8** of the *CNPE Scenarios and Solutions* book.

Next lab: **09 — Offer a deploy-kit WorkflowTemplate**.
