# Enforce a real AppArmor profile

Load an enforcing AppArmor profile named `book-deny-tmp`. Allow normal file/network use but deny writing `/tmp/**`. Create Pod `apparmor` in `book-cks-host`, BusyBox 1.37.0 sleeping3600, using `securityContext.appArmorProfile` with type Localhost. Prove `/etc/hostname` can be read, writes to `/root/allowed` work, and writes to `/tmp/blocked` fail because of AppArmor.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-08-host-security/solution.sh
bash /opt/book-labs/cks-08-host-security/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
