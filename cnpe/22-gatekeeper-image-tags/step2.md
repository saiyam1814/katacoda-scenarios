# Prove deny and allow

Floating tag — must be **denied**:

```bash
kubectl -n tag-lab create deploy floating-latest --image=busybox:latest \
  -- sleep 3600 ; echo "exit: $?"
```{{exec}}

Untagged image — must be **denied**:

```bash
kubectl -n tag-lab create deploy missing-tag --image=busybox \
  -- sleep 3600 ; echo "exit: $?"
```{{exec}}

Pinned tag — must be **created**:

```bash
kubectl -n tag-lab create deploy pinned-ok --image=busybox:1.36.1 \
  -- sleep 3600
kubectl -n tag-lab get deploy
```{{exec}}

The deny messages come straight from the template's Rego (`uses floating tag :latest`).

<details><summary>✦ If the denials don't happen</summary>

- The webhook needs a few seconds after the Constraint is created — retry
- `kubectl get forbidfloatingtag forbid-floating-tags -o yaml` — check
  `status.byPod` shows the webhook enforced generation
- `kubectl -n gatekeeper-system logs deploy/gatekeeper-controller-manager --tail=20`
- Gatekeeper's default `enforcementAction` is `deny` — if someone set `warn`, apply
  succeeds with a warning instead

</details>

<details><summary>✦ Audit view (bonus)</summary>

Gatekeeper also **audits existing** resources every 60s:

```bash
kubectl get forbidfloatingtag forbid-floating-tags \
  -o jsonpath='{.status.totalViolations}' ; echo
```{{exec}}

</details>
