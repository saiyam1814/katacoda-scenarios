# Consume a Secret without mounting API credentials

Create or replace Secret `database` with username `admin` and password `book-lab-secret`. Decode only its username into `~/book-labs/cks-04-serviceaccount/username`, mode0600. Create Pod `consumer` in `book-cks-secrets`, BusyBox 1.37.0 sleeping for 3600 seconds. Expose Secret `database` username as `DB_USER` and mount only its password at `/etc/db/password` read-only. Disable service-account token automount. The environment username must be admin, the file must contain book-lab-secret, and no API token may be mounted.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-04-serviceaccount/solution.sh
bash /opt/book-labs/cks-04-serviceaccount/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
