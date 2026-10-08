# Scenario — Bind reusable rules within one namespace

Book scenario(s): 22.

Create ServiceAccounts `demo-sa` and `demo2-sa` in `book-cka-rbac`. Create ClusterRole `book-cka-creators` permitting creation of Deployments and DaemonSets and bind it to `demo-sa` only in this namespace. Let `demo2-sa` create only Deployments. Neither account may read Secrets or create objects in `default`.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-01-rbac/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-01-rbac/solution-step-02.sh
bash /opt/book-labs/cka-01-rbac/solution-step-02.sh
```{{exec}}

A ClusterRole describes reusable permissions. The RoleBinding determines the namespace in which those namespaced permissions are granted.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-01-rbac/solution.sh`. Every step remains independently verifiable after all solutions finish.
