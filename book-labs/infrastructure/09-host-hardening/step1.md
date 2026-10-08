# Keep the reporting service useful and contained

The service `cks31-report` serves `/var/lib/cks31` on port 9998. It currently runs as root and listens externally. Use a systemd override to run it as `cks31:cks31`, bind only to `127.0.0.1`, set `NoNewPrivileges`, `PrivateTmp`, `ProtectSystem=strict`, `ProtectHome`, and `RestrictSUIDSGID`, and clear the capability bounding set. Keep write access to `/var/lib/cks31` only, apart from its private temporary directory.

Prove localhost HTTP still works, the non-loopback address rejects connections, `/etc` is read-only in the service mount namespace, and the service identity can still write its state directory. Do not disable SSH or change unrelated services.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-09-host-hardening/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-09-host-hardening/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-09-host-hardening/verify1.sh
```{{exec}}
