# Scenario — Create and diagnose Gateway API routes

Book scenario(s): 33.

Create Gateway public-web (class lab-gateway), HTTP listener http on80 for shop.cka.lab, allowing routes in the same namespace book-cka-routing. Attach HTTPRoute shop to that listener, path prefix/, backend Service web-gateway:80. Verify current Accepted/ResolvedRefs and real HTTP. Temporarily change the backend to missing, save its ResolvedRefs=False state to unresolved-route.json, then repair it. A request using the wrong hostname must not route to the app.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-14-gateway-ingress/verify-step-01.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-14-gateway-ingress/solution-step-01.sh
bash /opt/book-labs/cka-14-gateway-ingress/solution-step-01.sh
```{{exec}}



</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-14-gateway-ingress/solution.sh`. Every step remains independently verifiable after all solutions finish.
