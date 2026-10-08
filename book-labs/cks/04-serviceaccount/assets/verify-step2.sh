#!/usr/bin/env bash
set -Eeuo pipefail
export LAB_ID=cks-04-serviceaccount
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
require_ready
who=system:serviceaccount:book-cks-secrets:sam
can_i yes "$who" book-cks-secrets get secret/database
can_i no "$who" book-cks-secrets get secret/other
for verb in list watch create update patch delete; do can_i no "$who" book-cks-secrets "$verb" secrets; done
# resourceNames can restrict named operations; check the permitted Secret itself
# too, so a watch/modify grant on database cannot hide behind a collection denial.
for verb in watch update patch delete; do can_i no "$who" book-cks-secrets "$verb" secret/database; done
can_i yes "$who" book-cks-secrets create deployments.apps
can_i no "$who" book-cks-secrets delete deployments.apps
for verb in get list watch; do can_i no "$who" default "$verb" secrets; done
can_i no "$who" default get secret/database
pass "Step 2: Give Sam only the required permissions"
