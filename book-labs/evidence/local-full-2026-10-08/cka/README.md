# CKA full companion local validation

All 14 CKA application/platform lab groups passed: 38 starting-state rejections, 38 solved checks, 14 setups and 14 cleanups. The individual JSON records point to sanitized command logs and capture the final source hashes. This directory records local kind execution; it does not claim hosted Killercoda verification. Infrastructure chapters have separate evidence.

The longest solved CHECK was 3.57 seconds. Waits for images, controller reconciliation, ConfigMap refresh and Service programming are in setup or solution scripts, rather than long CHECK loops.

See summary.json for exact versions, environment differences and issues found and corrected during development. A few per-group durations were transcribed from the test runner’s observed output before the runner gained separate per-group JSON files; those records are explicitly marked and retain their corresponding command logs.
