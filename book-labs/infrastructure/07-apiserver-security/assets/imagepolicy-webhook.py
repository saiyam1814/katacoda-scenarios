import json
import ssl
from urllib.parse import urlsplit
from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if urlsplit(self.path).path != "/check":
            self.send_error(404)
            return
        request = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        spec = request.get("spec", {})
        images = [item["image"] for item in spec.get("containers", [])]
        approved = {"busybox:1.37.0", "nginx:1.28.0-alpine"}
        allowed = spec.get("namespace") != "cks16" or all(i in approved for i in images)
        response = {"apiVersion": "imagepolicy.k8s.io/v1alpha1", "kind": "ImageReview",
                    "status": {"allowed": allowed, "reason": "cks16 exact image allowlist"}}
        body = json.dumps(response).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

server = HTTPServer(("127.0.0.1", 9443), Handler)
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain("server.crt", "server.key")
context.load_verify_locations("ca.crt")
context.verify_mode = ssl.CERT_REQUIRED
server.socket = context.wrap_socket(server.socket, server_side=True)
server.serve_forever()
