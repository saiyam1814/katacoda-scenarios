#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
who=system:serviceaccount:book-cks-secrets:sam
can_i yes "$who" book-cks-secrets get secret/database
can_i no "$who" book-cks-secrets get secret/other
can_i no "$who" book-cks-secrets list secrets
can_i yes "$who" book-cks-secrets create deployments.apps
can_i no "$who" book-cks-secrets delete deployments.apps
can_i no "$who" default get secrets
pass "Step 2: Give Sam only the required permissions"
