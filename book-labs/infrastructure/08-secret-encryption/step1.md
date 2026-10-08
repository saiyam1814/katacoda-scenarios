# Enable encryption and migrate existing Secrets

The existing Secret `cks25/database` contains the lab marker `cks25-lab-marker`. Configure AES-CBC encryption for Secrets, with key `key1`, and identity as the read fallback. Generate a fresh 32-byte key in `/etc/kubernetes/encryption/config.yaml` with file mode 0600. Mount the directory read-only and enable the encryption provider on the API server.

Rewrite existing Secrets, including `database`. Prove Kubernetes still returns the marker while the actual etcd value begins `k8s:enc:aescbc:v1:key1:` and does not contain plaintext. This requires real storage encryption, not base64 output.

Keep encryption enabled for this session. Restoring only an unencrypted API manifest would strand ciphertext; use a fresh environment to reset.

Try the task yourself first. Read the worked solution only when you need it:

```bash
cat /opt/book-labs/infra-08-secret-encryption/solution1.sh
```{{exec}}

Run the solution:

```bash
bash /opt/book-labs/infra-08-secret-encryption/solution1.sh
```{{exec}}

Check the actual result, then use **CHECK**:

```bash
bash /opt/book-labs/infra-08-secret-encryption/verify1.sh
```{{exec}}
