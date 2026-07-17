# Tenant isolated! 🎉

You built the two-policy pattern used in virtually every multi-tenant platform:
a namespace-wide **default deny**, plus **surgical allows**.

## Key facts to remember

- `podSelector: {}` = every Pod in the namespace
- Declaring a `policyType` with no rules = deny everything of that type
- Policies are **additive** - there is no "deny rule"; you only widen what is allowed
- `namespaceSelector` matches **labels**; use `kubernetes.io/metadata.name` to match by name
- Always allow **UDP 53** egress when you start restricting egress, or everything breaks
  in confusing ways
- Enforcement needs a CNI that supports NetworkPolicy (Cilium, Calico, …) - the API
  accepts policies even when nothing enforces them

📖 This lab is **Chapter 4** of the *CNPE Scenarios and Solutions* book.

Next lab: **05 - Right-size three services with OpenCost**.
