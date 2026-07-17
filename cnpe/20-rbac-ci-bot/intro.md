# Give a CI Bot Least-Privilege RBAC

**Domain:** Security and Policy Enforcement &nbsp;|&nbsp; **Suggested time:** 8 minutes

The CI system deploys into namespace `build-room` using a ServiceAccount. Security
reviewed the current setup ("cluster-admin, obviously") and had opinions.

**Your task - all in namespace `build-room`:**

1. ServiceAccount **`ci-bot`**
2. Role **`ci-bot`** allowing exactly:
   - **Deployments** (apps group): `get, list, watch, create, update, patch`
   - **ConfigMaps** (core group): `get, list, watch, create, update, patch`
3. RoleBinding **`ci-bot`** connecting the two

Then **prove** with `kubectl auth can-i` that the bot:

- ✅ can create Deployments in `build-room`
- ❌ cannot delete Deployments in `build-room`
- ❌ cannot create Deployments in `default`
- ❌ cannot read Secrets in `build-room`

Click **START** when ready.
