# Create SA, Role and RoleBinding

All three can be created imperatively - fastest correct answer in the exam:

<details><summary>✦ Tip</summary>

```plain
kubectl create role --help | head -12
kubectl create rolebinding --help | head -12
```{{copy}}

Note: Deployments live in the `apps` API group → `--resource=deployments.apps`.
No `delete` in the verb list - least privilege means *exactly* what was asked.

</details>

<details><summary>✅ Solution - imperative</summary>

```bash
kubectl -n build-room create serviceaccount ci-bot

kubectl -n build-room create role ci-bot \
  --verb=get,list,watch,create,update,patch \
  --resource=deployments.apps,configmaps

kubectl -n build-room create rolebinding ci-bot \
  --role=ci-bot \
  --serviceaccount=build-room:ci-bot
```{{exec}}

</details>

<details><summary>✅ Solution - declarative equivalent</summary>

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ci-bot
  namespace: build-room
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ci-bot
  namespace: build-room
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ci-bot
  namespace: build-room
subjects:
  - kind: ServiceAccount
    name: ci-bot
    namespace: build-room
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ci-bot
```{{copy}}

</details>

Inspect what you built:

```bash
kubectl -n build-room describe role ci-bot
```{{exec}}
