# Remove an unwanted host listener

Find the process and systemd unit listening on TCP9999. Save `ss -lntp` evidence to `listener-before.txt` and the unit name to `listener-unit.txt` in the work directory. Stop and disable only that unit. Kubernetes and the required Falco service must stay healthy.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-08-host-security/solution.sh
bash /opt/book-labs/cks-08-host-security/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
