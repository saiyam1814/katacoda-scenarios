#!/usr/bin/env python3
"""Run independent traffic checks concurrently within the hosted CHECK budget."""
import concurrent.futures
import subprocess
import sys

ALLOW_SCRIPT = r'''
command -v wget >/dev/null || { echo 'wget is unavailable' >&2; exit 1; }
body=$(wget -T 2 -qO- "$1") || { echo 'Expected HTTP request failed' >&2; exit 1; }
case "$body" in
  *'Welcome to nginx!'*) printf 'ALLOW_OK\n' ;;
  *) echo 'Unexpected API response' >&2; exit 1 ;;
esac
'''
DENY_SCRIPT = r'''
command -v wget >/dev/null || { echo 'wget is unavailable' >&2; exit 1; }
for attempt in 1 2; do
  if wget -T 2 -qO- "$1" >/dev/null 2>&1; then
    echo 'Connection succeeded but must be denied' >&2
    exit 1
  fi
  # A marker after each attempt proves that the remote shell completed it.
  printf 'DENY_OK_%s\n' "$attempt"
done
'''


def probe(namespace, pod, ip, allowed):
    label = f'{namespace}/{pod} -> {ip}'
    script = ALLOW_SCRIPT if allowed else DENY_SCRIPT
    command = ['kubectl', '--request-timeout=8s', '-n', namespace, 'exec', pod,
               '--', 'sh', '-c', script, 'book-network-probe', 'http://' + ip]
    try:
        result = subprocess.run(command, text=True, capture_output=True, timeout=8)
    except subprocess.TimeoutExpired:
        return f'{label}: exec timed out; retry CHECK when the environment is ready'
    if result.returncode != 0:
        detail = result.stderr.strip().splitlines()
        return f'{label}: ' + (detail[0] if detail else 'remote probe did not complete')
    expected = 'ALLOW_OK' if allowed else 'DENY_OK_1\nDENY_OK_2'
    if result.stdout.strip() != expected:
        return f'{label}: missing remote completion markers; an exec failure cannot count as denied traffic'
    return None


def main(api_ip, admin_ip):
    cases = [
        ('book-cks-green', 'trusted', api_ip, True),
        ('book-cks-network', 'local-approved', api_ip, True),
        ('book-cks-green', 'untrusted', api_ip, False),
        ('book-cks-blue', 'trusted', api_ip, False),
        ('book-cks-green', 'trusted', admin_ip, False),
        ('book-cks-network', 'local-unapproved', api_ip, False),
        ('book-cks-blue', 'local-approved', api_ip, False),
        ('book-cks-network', 'local-approved', admin_ip, False),
    ]
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(cases)) as workers:
        failures = list(workers.map(lambda case: probe(*case), cases))
    for failure in failures:
        if failure:
            print('FAIL: ' + failure, file=sys.stderr)
    if any(failures):
        return 1
    print('PASS: both allowed API peers and all twelve denied connection attempts')
    return 0


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('Usage: network_probe.py API_IP ADMIN_IP')
    raise SystemExit(main(sys.argv[1], sys.argv[2]))
