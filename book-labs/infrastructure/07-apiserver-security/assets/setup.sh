#!/usr/bin/env bash
LAB_ID=infra-07-apiserver-security
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/infra.sh"

setup_begin
api_wait
ns cks06
ns cks16
mkdir -p /etc/kubernetes/audit /var/log/kubernetes/audit /etc/kubernetes/image-policy
cp /etc/kubernetes/manifests/kube-apiserver.yaml "$WORK_DIR/kube-apiserver.before.yaml"
cd /etc/kubernetes/image-policy
umask 077
openssl req -x509 -newkey rsa:2048 -nodes -days 2 -subj /CN=cks16-ca -keyout ca.key -out ca.crt 2>/dev/null
openssl req -newkey rsa:2048 -nodes -subj /CN=localhost -keyout server.key -out server.csr 2>/dev/null
printf '%s\n' 'subjectAltName=DNS:localhost,IP:127.0.0.1' 'extendedKeyUsage=serverAuth' > server.ext
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 2 -extfile server.ext -out server.crt 2>/dev/null
openssl req -newkey rsa:2048 -nodes -subj /CN=apiserver -keyout client.key -out client.csr 2>/dev/null
printf '%s\n' 'extendedKeyUsage=clientAuth' > client.ext
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 2 -extfile client.ext -out client.crt 2>/dev/null
cp "$ASSET_DIR/imagepolicy-webhook.py" server.py
cat > /etc/systemd/system/cks16-policy.service <<'EOF'
[Unit]
Description=CKS image policy exercise
After=network.target
[Service]
WorkingDirectory=/etc/kubernetes/image-policy
ExecStart=/usr/bin/python3 /etc/kubernetes/image-policy/server.py
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart cks16-policy
for n in $(seq 1 20); do
 curl -fsS --max-time 2 --cacert ca.crt --cert client.crt --key client.key -H 'Content-Type: application/json' -d '{"spec":{"namespace":"cks16","containers":[{"image":"busybox:1.37.0"}]}}' https://127.0.0.1:9443/check > "$STATE_DIR/webhook-baseline.json" && break
 sleep 1
done
cat "$STATE_DIR/webhook-baseline.json" | json_check 'd["status"]["allowed"] == True' 'TLS image service did not permit its baseline request'
setup_done
