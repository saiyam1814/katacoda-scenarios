# Detect an actual interactive container shell with Falco

Add local Falco rule `Book Interactive Container Shell` in `/etc/falco/rules.d/book-shell.yaml`. Detect execve/execveat exits for sh/bash/ash in containers with a nonzero TTY. Preserve vendor rules and metadata plugins. Enable JSON output to `/var/log/falco/book-shell.jsonl`, with all-rule matching. Restart `book-falco`. Generate a real TTY shell using the provided `generate-shell.py` helper, then both a non-TTY shell and a non-interactive cat. Neither negative control should trigger this interactive-shell rule. Extract matching actual timestamp, container ID and container name to `falcologs.json`. CHECK generates new positive and negative events and requires valid container metadata.

<details><summary>Worked solution</summary>

The complete group solution is readable and runnable in the terminal:

```bash
cat /opt/book-labs/cks-08-host-security/solution.sh
bash /opt/book-labs/cks-08-host-security/solution.sh
```{{exec}}

It solves all steps in this group. Use CHECK for each step to verify its own result.
</details>
