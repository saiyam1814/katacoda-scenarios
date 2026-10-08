# Scenario — Create and diagnose custom resources

Book scenario(s): 30.

Inspect the Certificate CRD schema and save its DNS-names field schema to dnsnames-schema.json. In book-cka-certificates create SelfSigned Issuer lab-selfsigned and Certificate app for DNS name app.cka.lab, writing Secret app-tls. Wait for Ready and save only the public certificate to certificate.pem. Then create Certificate missing-issuer referring to nonexistent Issuer absent, with missing-tls as its Secret. Prove reconciliation fails for that object and no Secret is issued; keep the healthy app certificate.

## Verify your work

Use **CHECK**. The verifier examines the real objects and the stated result; a manifest existing on disk is not enough.

```bash
bash /opt/book-labs/cka-13-helm-certificates/verify-step-02.sh
```{{exec}}

<details><summary>Solution</summary>

Try the task first. Then read and run this step's worked solution:

```bash
cat /opt/book-labs/cka-13-helm-certificates/solution-step-02.sh
bash /opt/book-labs/cka-13-helm-certificates/solution-step-02.sh
```{{exec}}

The CRD gives the API a schema. The running controller performs reconciliation and issues the Secret. A successfully created Certificate object alone is not proof of success.

</details>

To run every worked solution in this grouped lab, use `bash /opt/book-labs/cka-13-helm-certificates/solution.sh`. Every step remains independently verifiable after all solutions finish.
