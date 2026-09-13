#!/usr/bin/env bash
# Live-host refuse guards for restore/sync and rewrite.
# Sourced by deploy/sync-runtime.sh. Safe to source from tests.

sync_refresh_live_consumer() {
  SYNC_ENV_LC="$(lower_s "${SYNC_ENV:-}")"
  DEPLOY_ENV_LC="$(lower_s "${SHOPWARE_DEPLOY_ENV:-}")"
  SHOP_BASE_LC="$(lower_s "$(basename "${COMPOSE_DIR:-.}")")"
  HOST_SHORT_LC="$(lower_s "$(hostname -s 2>/dev/null || hostname)")"
}

is_live_consumer() {
  [[ "$SYNC_ENV_LC" == "live" ]] && return 0
  [[ "$DEPLOY_ENV_LC" == "live" ]] && return 0
  [[ "$SHOP_BASE_LC" == "live" ]] && return 0
  [[ "$HOST_SHORT_LC" == "live" ]] && return 0
  return 1
}

assert_not_live_restore() {
  if is_live_consumer; then
    if [[ "${SYNC_ALLOW_LIVE_RESTORE:-}" == "1" ]]; then
      log "WARNING: SYNC_ALLOW_LIVE_RESTORE=1 — restoring onto a live host (disaster recovery). This is not the live→staging sync path. See deploy/backup-runtime.md."
      return
    fi
    die "Refusing restore/sync on a live host (SYNC_ENV=${SYNC_ENV:-unset}, SHOPWARE_DEPLOY_ENV=${SHOPWARE_DEPLOY_ENV:-unset}, checkout=$(basename "$COMPOSE_DIR"), hostname=${HOST_SHORT_LC}). Runtime sync is pull-only onto staging/playground/dev. Live backups use deploy/backup-runtime.sh; live restore is BACKUP_ALLOW_LIVE_RESTORE=1 (quarterly DR drill)."
  fi
}


# Rewrite is never allowed on live, including SYNC_ALLOW_LIVE_RESTORE=1.
assert_not_live_rewrite() {
  if ! sync_rewrite_requested; then
    return
  fi
  if ! sync_rewrite_assert_not_live \
    "${SYNC_ENV:-}" \
    "${SHOPWARE_DEPLOY_ENV:-}" \
    "$(basename "$COMPOSE_DIR")" \
    "$HOST_SHORT_LC"
  then
    exit 1
  fi
}
