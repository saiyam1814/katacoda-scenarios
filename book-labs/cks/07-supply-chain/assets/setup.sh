#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-07-supply-chain
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
setup_begin

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq jq curl ca-certificates skopeo buildah python3-yaml
mkdir -p "$STATE_DIR/downloads" "$WORK_DIR/build" "$WORK_DIR/release" "$WORK_DIR/reports"
cd "$STATE_DIR/downloads"
curl -fL --retry 3 -o trivy.tgz https://github.com/aquasecurity/trivy/releases/download/v0.75.0/trivy_0.75.0_Linux-64bit.tar.gz
curl -fL --retry 3 -o trivy.sha https://github.com/aquasecurity/trivy/releases/download/v0.75.0/trivy_0.75.0_checksums.txt
printf '%s  trivy.tgz\n' "$(awk '$2=="trivy_0.75.0_Linux-64bit.tar.gz" {print $1}' trivy.sha)" | sha256sum -c -
tar -xzf trivy.tgz trivy
install -m 0755 trivy /usr/local/bin/trivy
curl -fL --retry 3 -o kubesec.tgz https://github.com/controlplaneio/kubesec/releases/download/v2.14.2/kubesec_linux_amd64.tar.gz
curl -fL --retry 3 -o kubesec.sha https://github.com/controlplaneio/kubesec/releases/download/v2.14.2/kubesec_checksums.txt
printf '%s  kubesec.tgz\n' "$(awk '$2=="kubesec_linux_amd64.tar.gz" {print $1}' kubesec.sha)" | sha256sum -c -
tar -xzf kubesec.tgz kubesec
install -m 0755 kubesec /usr/local/bin/kubesec
curl -fL --retry 3 -o /usr/local/bin/cosign https://github.com/sigstore/cosign/releases/download/v3.1.3/cosign-linux-amd64
curl -fL --retry 3 -o cosign.sha https://github.com/sigstore/cosign/releases/download/v3.1.3/cosign_checksums.txt
printf '%s  /usr/local/bin/cosign\n' "$(awk '$2=="cosign-linux-amd64" {print $1}' cosign.sha)" | sha256sum -c -
chmod 755 /usr/local/bin/cosign
curl -fL --retry 3 https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl.sha256 -o "$STATE_DIR/trusted-kubectl.sha256"
trivy --version
cosign version
kubesec version
trivy image --download-db-only --timeout 10m
# Resolve actual registry content and preload the modest scan target.
skopeo inspect docker://docker.io/library/alpine:3.20.3 > "$STATE_DIR/image-inspect.json"
printf 'docker.io/library/alpine@%s\n' "$(jq -r .Digest "$STATE_DIR/image-inspect.json")" > "$WORK_DIR/scan-image.txt"
trivy image --scanners vuln --format json --output "$STATE_DIR/baseline-scan.json" --timeout 10m "$(cat "$WORK_DIR/scan-image.txt")"
reset_ns book-cks-supply
cat > "$WORK_DIR/insecure.yaml" <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: scan-target, namespace: book-cks-supply}
spec:
  containers:
  - name: app
    image: busybox:1.37.0
    command: [sleep, '3600']
    securityContext: {privileged: true, runAsUser: 0}
YAML
cat > "$WORK_DIR/build/Dockerfile" <<'EOF'
FROM busybox:latest
ENV APP_TOKEN=do-not-ship-this
COPY . /site
USER root
CMD ["httpd","-f","-p","8080","-h","/site"]
EOF
printf 'book-secure-web\n' > "$WORK_DIR/build/index.html"
printf 'do-not-ship-this\n' > "$WORK_DIR/build/developer-secret.txt"
printf '{"name":"book-release","version":"1.0"}\n' > "$WORK_DIR/release/manifest.json"

reset_ns book-cks-scan
for n in $(seq 1 30); do kubectl -n book-cks-scan get sa default >/dev/null 2>&1 && break; sleep 1; done
image=$(cat "$WORK_DIR/scan-image.txt")
kubectl -n book-cks-scan run risk --image="$image" --overrides='{"spec":{"initContainers":[{"name":"prepare","image":"busybox:1.37.0","command":["true"]}]}}' --command -- sleep 3600
kubectl -n book-cks-scan run utility --image=busybox:1.37.0 --command -- sleep 3600
ready_pod book-cks-scan risk
ready_pod book-cks-scan utility
python3 "$(dirname "$0")/scan-namespace.py" "$STATE_DIR/namespace-baseline"
setup_done
