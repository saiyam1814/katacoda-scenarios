# Least privilege, proven! 🎉

The bot can ship Deployments and ConfigMaps in its own namespace — nothing more,
nowhere else. And you *proved* it, which is the part graders score.

## Key facts to remember

- Role + RoleBinding = namespaced; ClusterRole + ClusterRoleBinding = everywhere.
  A ClusterRole bound by a *RoleBinding* applies only in that namespace (common pattern)
- `kubectl create role --verb=... --resource=deployments.apps,configmaps` beats YAML
  under time pressure
- ServiceAccount identity string: `system:serviceaccount:<ns>:<name>`
- `kubectl auth can-i <verb> <resource> -n <ns> --as=<identity>` — the RBAC lie detector
- RBAC is **allow-only**; there is no deny rule. Whatever is not granted is denied

📖 This lab is **Chapter 20** of the *CNPE Scenarios and Solutions* book.

Next lab: **21 — Warn on baseline PSS across fleet namespaces**.
