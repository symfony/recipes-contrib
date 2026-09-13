#!/usr/bin/env bash
# Load all runtime-sync libraries. Sourced by deploy/sync-runtime.sh.
# Caller must set SCRIPT_DIR to deploy/ and use set -euo pipefail.
# Safe to source from tests (defines functions + defaults helpers only).

_SYNC_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=identity.sh
source "${_SYNC_LIB_DIR}/identity.sh"
# shellcheck source=sync-log.sh
source "${_SYNC_LIB_DIR}/sync-log.sh"
# shellcheck source=compose.sh
source "${_SYNC_LIB_DIR}/compose.sh"
# shellcheck source=sync-identity.sh
source "${_SYNC_LIB_DIR}/sync-identity.sh"
# shellcheck source=sync-dump.sh
source "${_SYNC_LIB_DIR}/sync-dump.sh"
# shellcheck source=sync-rewrite.sh
source "${_SYNC_LIB_DIR}/sync-rewrite.sh"
# shellcheck source=sync-live.sh
source "${_SYNC_LIB_DIR}/sync-live.sh"
# shellcheck source=sync-ssh.sh
source "${_SYNC_LIB_DIR}/sync-ssh.sh"
# shellcheck source=sync-db.sh
source "${_SYNC_LIB_DIR}/sync-db.sh"
# shellcheck source=sync-volumes.sh
source "${_SYNC_LIB_DIR}/sync-volumes.sh"
# shellcheck source=sync-app.sh
source "${_SYNC_LIB_DIR}/sync-app.sh"
# shellcheck source=sync-commands.sh
source "${_SYNC_LIB_DIR}/sync-commands.sh"
