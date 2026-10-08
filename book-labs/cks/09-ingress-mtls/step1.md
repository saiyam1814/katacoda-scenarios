# Serve an Ingress with a trusted TLS hostname

Create a two-day self-signed test certificate with SAN `book.test`, and TLS Secret `book-tls` in `book-cks-ingress`. Create Ingress `web` using class `traefik`, TLS host `book.test`, and Service `web:80`. Save the certificate/key as `book.crt` and `book.key` in the work directory. The installed controller exposes HTTPS at node IP (in `node-ip.txt`) port30443. Verify the response using the certificate as a trust anchor; a mismatched TLS hostname and an incorrect HTTP Host header must fail.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-09-ingress-mtls/solution.sh
bash /opt/book-labs/cks-09-ingress-mtls/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
