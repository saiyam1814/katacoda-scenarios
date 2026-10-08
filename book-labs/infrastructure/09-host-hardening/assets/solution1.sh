#!/usr/bin/env bash
LAB_ID=infra-09-host-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

require_ready
mkdir -p /etc/systemd/system/cks31-report.service.d
cat > /etc/systemd/system/cks31-report.service.d/hardening.conf <<'EOF'
[Service]
User=cks31
Group=cks31
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/cks31
CapabilityBoundingSet=
RestrictSUIDSGID=true
ExecStart=
ExecStart=/usr/bin/python3 -m http.server 9998 --bind 127.0.0.1 --directory /var/lib/cks31
EOF
systemctl daemon-reload
systemctl restart cks31-report
for n in $(seq 1 20); do curl --noproxy '*' -fsS --max-time 2 http://127.0.0.1:9998/ >/dev/null && break; sleep 1; done
bash "$ASSET_DIR/verify1.sh"
