# Write actual audit records without leaking Secrets

Enable live audit logging. Log Secret operations at Metadata level. Log Deployment create/update/patch/delete in `cks06` at RequestResponse. Write `/var/log/kubernetes/audit/audit.log`, max age 30 days, max backup 10, max size 100 MB. Use blocking audit log mode so each completed request is available to the check immediately.

Create Deployment `web` using `nginx:1.28.0-alpine` and Secret `marker` with token `cks06-sensitive-marker` in `cks06`. Preserve existing API flags and mounts. The check generates fresh requests and reads real JSON audit records; it rejects leaked request/response bodies on Secret events.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-07-apiserver-security/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-07-apiserver-security/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-07-apiserver-security/verify1.sh
```{{exec}}
