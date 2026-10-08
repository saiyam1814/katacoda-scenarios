ensure_helm() {
 HELM=$(type -P helm || true)
 if [[ -z "$HELM" ]]; then
  mkdir -p "$WORK_DIR/bin" "$WORK_DIR/helm-download"
  os=$(uname -s | tr '[:upper:]' '[:lower:]'); arch=$(uname -m)
  case "$arch" in x86_64) arch=amd64;; aarch64) arch=arm64;; esac
  archive="helm-v3.19.0-${os}-${arch}.tar.gz"
  curl -fsSL --retry 3 "https://get.helm.sh/$archive" -o "$WORK_DIR/helm-download/$archive"
  curl -fsSL --retry 3 "https://get.helm.sh/$archive.sha256sum" -o "$WORK_DIR/helm-download/checksum"
  python3 - "$WORK_DIR/helm-download/$archive" "$WORK_DIR/helm-download/checksum" <<'PYHELM'
import hashlib,pathlib,sys
assert hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest()==pathlib.Path(sys.argv[2]).read_text().split()[0], 'Helm archive checksum mismatch'
PYHELM
  tar -xzf "$WORK_DIR/helm-download/$archive" -C "$WORK_DIR/helm-download"
  cp "$WORK_DIR/helm-download/$os-$arch/helm" "$WORK_DIR/bin/helm"
  chmod +x "$WORK_DIR/bin/helm"
  HELM="$WORK_DIR/bin/helm"
 fi
 "$HELM" version --short
}
