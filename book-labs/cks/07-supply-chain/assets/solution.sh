#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
trivy image --skip-db-update --scanners vuln --format json --output "$WORK_DIR/reports/image.json" --timeout 10m "$(cat "$WORK_DIR/scan-image.txt")"
jq -r '.Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH" or .Severity=="CRITICAL") | [.VulnerabilityID,.PkgName,.InstalledVersion,(.FixedVersion//"")] | @tsv' "$WORK_DIR/reports/image.json" > "$WORK_DIR/reports/high-critical.tsv"
cat > "$WORK_DIR/build/Dockerfile" <<'EOF'
FROM docker.io/library/busybox:1.37.0
COPY index.html /site/index.html
USER 1000:1000
EXPOSE 8080
CMD ["httpd","-f","-p","8080","-h","/site"]
EOF
printf 'developer-secret.txt\n.git\n' > "$WORK_DIR/build/.dockerignore"
buildah --storage-driver=vfs bud --isolation=chroot -t localhost/book-cks-web:v1 "$WORK_DIR/build"
buildah --storage-driver=vfs push localhost/book-cks-web:v1 oci-archive:"$WORK_DIR/web.oci.tar":localhost/book-cks-web:v1
ctr -n k8s.io images import "$WORK_DIR/web.oci.tar"
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: book-cks-supply}
spec:
  replicas: 1
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      securityContext: {runAsUser: 1000, runAsGroup: 1000, runAsNonRoot: true, seccompProfile: {type: RuntimeDefault}}
      containers:
      - name: web
        image: localhost/book-cks-web:v1
        imagePullPolicy: Never
        ports: [{containerPort: 8080}]
        securityContext: {readOnlyRootFilesystem: true, allowPrivilegeEscalation: false, capabilities: {drop: [ALL]}}
---
apiVersion: v1
kind: Service
metadata: {name: web, namespace: book-cks-supply}
spec:
  selector: {app: web}
  ports: [{port: 8080, targetPort: 8080}]
YAML
ready_deploy book-cks-supply web
kubesec scan "$WORK_DIR/insecure.yaml" > "$WORK_DIR/reports/kubesec-before.json" || test $? -eq 2
cat > "$WORK_DIR/repaired.yaml" <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: scan-target, namespace: book-cks-supply}
spec:
  securityContext: {runAsNonRoot: true, runAsUser: 1000, seccompProfile: {type: RuntimeDefault}}
  containers:
  - name: app
    image: busybox:1.37.0
    command: [sleep, '3600']
    securityContext: {privileged: false, readOnlyRootFilesystem: true, allowPrivilegeEscalation: false, capabilities: {drop: [ALL]}}
YAML
kubesec scan "$WORK_DIR/repaired.yaml" > "$WORK_DIR/reports/kubesec-after.json"
kubectl -n book-cks-supply delete pod scan-target --ignore-not-found
kubectl apply -f "$WORK_DIR/repaired.yaml"
ready_pod book-cks-supply scan-target
mkdir -p "$WORK_DIR/bin"
curl -fL --retry 3 https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl -o "$WORK_DIR/kubectl.download"
curl -fL --retry 3 https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl.sha256 -o "$WORK_DIR/kubectl.sha256"
printf '%s  %s\n' "$(cat "$WORK_DIR/kubectl.sha256")" "$WORK_DIR/kubectl.download" | sha256sum -c -
install -m 0755 "$WORK_DIR/kubectl.download" "$WORK_DIR/bin/kubectl"
cp "$WORK_DIR/kubectl.download" "$WORK_DIR/kubectl.tampered"
printf changed >> "$WORK_DIR/kubectl.tampered"
if printf '%s  %s\n' "$(cat "$WORK_DIR/kubectl.sha256")" "$WORK_DIR/kubectl.tampered" | sha256sum -c -; then exit 1; fi
trivy image --format cyclonedx --output "$WORK_DIR/reports/sbom.cdx.json" --timeout 10m "$(cat "$WORK_DIR/scan-image.txt")"
trivy sbom --skip-db-update --format json --output "$WORK_DIR/reports/sbom-scan.json" "$WORK_DIR/reports/sbom.cdx.json"
python3 - "$WORK_DIR/reports" <<'PYDECISION'
import json,pathlib,sys
p=pathlib.Path(sys.argv[1]);d=json.load(open(p/'sbom-scan.json'));blocked=any(v['Severity'] in ('HIGH','CRITICAL') for r in d.get('Results',[]) for v in r.get('Vulnerabilities',[]));(p/'decision.txt').write_text(('BLOCK' if blocked else 'PASS')+'\n')
PYDECISION
export COSIGN_PASSWORD=book-lab-key
cd "$WORK_DIR"
if ! test -f cosign.key; then cosign generate-key-pair; fi
cp cosign.pub release/cosign.pub
cosign sign-blob --yes --key cosign.key --bundle release/manifest.bundle.json release/manifest.json
cosign verify-blob --key release/cosign.pub --bundle release/manifest.bundle.json release/manifest.json
cp release/manifest.json release/changed.json
printf '\nchanged\n' >> release/changed.json
if cosign verify-blob --key release/cosign.pub --bundle release/manifest.bundle.json release/changed.json; then exit 1; fi
unset COSIGN_PASSWORD

python3 "$(dirname "$0")/scan-namespace.py" "$WORK_DIR/reports/namespace"
