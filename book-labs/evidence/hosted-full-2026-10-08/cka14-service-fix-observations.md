# CKA14 ClusterIP fix: fresh hosted retake

Source commit: d4fa0a5. Normal Chrome extension terminal, existing tab323929543. Passing VM c733cbae3646703f. This records actual UI and terminal observations, not a server-side replay.

1. First automatic delivery had old aggregate05305ac6336a080851cc7537a414574bcb50930033289437a801d228c366315c. It was saved as stale evidence, exited and replaced with a fresh VM.
2. Fresh automatic delivery: all11 assets matched aggregate203d6b3d74759bc3b6cbe5d9abba134c325a52853a27c4d46e69df3b30b945ba. Individual hashes were printed and captured. No files were replaced manually.
3. Setup ready sentinel existed, no error sentinel was listed, setup log ended Ready. The actual Traefik Service reported ClusterIP.
4. Both unsolved direct verifiers failed with exit1: missing HTTPRoute shop and missing standard Ingress/TLS Secret reference.
5. Supplied solution1 exited0; verifier1 printed PASS and exited0. Actual browser CHECK advanced to HTTPS step2. A brief browser transport timeout was resolved by reconnecting to the same tab; the observed step2 state confirms advancement.
6. Supplied solution2 exited0; verifier2 printed PASS and exited0. The printed TLS mismatch is the intentional negative/control test; the verifier also checked valid trusted HTTPS.
7. Actual browser CHECK2 produced the matching lab’s Scenario completed page with BACK, ASK/HELP and SCENARIOS. Final screenshot and DOM capture are retained.

The corrected chart value was automatically delivered and exercised. This retake validates the two companion steps; it does not execute every manuscript command.
