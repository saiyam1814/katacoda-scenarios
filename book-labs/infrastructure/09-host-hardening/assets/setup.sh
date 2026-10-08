#!/usr/bin/env bash
LAB_ID=infra-09-host-hardening
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

setup_begin
id cks31 >/dev/null 2>&1 || useradd --system --user-group --no-create-home --shell /usr/sbin/nologin cks31
systemctl stop cks31-report 2>/dev/null || true
rm -rf /etc/systemd/system/cks31-report.service.d
install -d -m 0750 -o cks31 -g cks31 /var/lib/cks31
printf 'cks31 report\n' > /var/lib/cks31/index.html
chown cks31:cks31 /var/lib/cks31/index.html
cat > /etc/systemd/system/cks31-report.service <<'EOF'
[Unit]
Description=CKS local reporting service
After=network.target
[Service]
ExecStart=/usr/bin/python3 -m http.server 9998 --directory /var/lib/cks31
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start cks31-report
for n in $(seq 1 20); do curl --noproxy '*' -fsS --max-time 2 http://127.0.0.1:9998/ >/dev/null && break; sleep 1; done
curl --noproxy '*' -fsS --max-time 2 http://127.0.0.1:9998/ >/dev/null
ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++)if($i=="src"){print $(i+1);exit}}' > "$STATE_DIR/host-ip"
test -s "$STATE_DIR/host-ip"
curl --noproxy '*' -fsS --max-time 2 "http://$(cat "$STATE_DIR/host-ip"):9998/" >/dev/null
setup_done
