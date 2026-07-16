# Prove the boundary with auth can-i

`kubectl auth can-i` lets you impersonate the bot without minting tokens. The identity
format is `system:serviceaccount:<namespace>:<name>`.

Run the four probes:

```bash
echo -n "create deploy in build-room (want yes): "
kubectl auth can-i create deployments -n build-room \
  --as=system:serviceaccount:build-room:ci-bot

echo -n "delete deploy in build-room (want no):  "
kubectl auth can-i delete deployments -n build-room \
  --as=system:serviceaccount:build-room:ci-bot

echo -n "create deploy in default (want no):     "
kubectl auth can-i create deployments -n default \
  --as=system:serviceaccount:build-room:ci-bot

echo -n "get secrets in build-room (want no):    "
kubectl auth can-i get secrets -n build-room \
  --as=system:serviceaccount:build-room:ci-bot
```{{exec}}

All four answers as expected? Record the proof (exam tasks often ask you to save
command output):

```bash
kubectl auth can-i --list -n build-room \
  --as=system:serviceaccount:build-room:ci-bot | tee /root/ci-bot-perms.txt
```{{exec}}

<details><summary>✦ Reading `auth can-i --list`</summary>

You will also see rows like `selfsubjectreviews` — every authenticated identity gets
those. The interesting rows are your two: `deployments.apps` and `configmaps`, each
with the six verbs. No `secrets` row = the bot cannot even read Secrets. 

</details>
