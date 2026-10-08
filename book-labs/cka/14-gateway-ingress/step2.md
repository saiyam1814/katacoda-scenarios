# Scenario — Expose HTTPS with a verified certificate

Book scenario(s): 34.

Using prepared web.key and web.crt, create TLS Secret web-tls and Ingress web in book-cka-routing, class lab-ingress, hostname web.cka.lab, Prefix/, backend Service web-ingress:80. Use the prepared client with /trust/ca.crt to prove HTTPS succeeds with certificate verification. Prove the certificate does not match wrong.cka.lab. Keep the Gateway route working.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-14-gateway-ingress/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-14-gateway-ingress/solution-step-02.sh
bash /opt/book-labs/cka-14-gateway-ingress/solution-step-02.sh
```{{exec}}

The training client explicitly trusts the public certificate. Host routing and certificate identity are separate checks; a TLS failure alone does not prove an HTTP routing rule.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-14-gateway-ingress/solution.sh`. Every step remains independently verifiable after all solutions finish.
