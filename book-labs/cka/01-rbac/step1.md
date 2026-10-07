# Scenario

In namespace `book-cka-rbac`, create ServiceAccount `release-bot`, Role `release-manager` and RoleBinding `release-manager`.

The account must be able to `get`, `list`, `watch`, `update` and `patch` Deployments, and `get`, `list`, `watch` ConfigMaps. It must not create or delete Deployments, read Secrets, or manage workloads in `default`. Keep permissions within the requested namespace.

## Validate

Use the **CHECK** button when you are done. You can also run:

```bash
bash /opt/book-labs/cka-01-rbac/verify.sh
```{{exec}}

Read the failed check and inspect the object before changing anything else.

<details><summary>Solution</summary>

The complete solution is available inside the environment. Read it first, then run it if needed:

```bash
cat /opt/book-labs/cka-01-rbac/solution.sh
bash /opt/book-labs/cka-01-rbac/solution.sh
```{{exec}}

The authorization checks prove allowed and forbidden actions. A Role object by itself does not grant access; the binding connects it to the identity.

</details>
