#!/usr/bin/env bash
# Opt-in sales_channel_domain rewrite after sync/restore.
# Sourced by deploy/sync-runtime.sh. Safe to source from tests (no side effects).
#
# Bash keeps “rewrite requested?” and live-refuse guards. The rewrite itself is
# bin/console fyrst:sales-channel:rewrite-urls in fyrst/shopware-cd (not SQL here).

# True when the operator opted in (either a single new origin or an old→new map).
sync_rewrite_requested() {
  [[ -n "${SYNC_REWRITE_APP_URL:-}" || -n "${SYNC_REWRITE_URL_MAP:-}" ]]
}

# Append fyrst:sales-channel:rewrite-urls options onto the named array.
# $1: nameref of an existing array
# $2: checkout directory basename (e.g. acme-staging)
# --dry-run is added only when DRY_RUN is 1 (DRY_RUN=0 must not pass the flag).
sync_rewrite_append_console_args() {
  local -n _sync_rewrite_args=$1
  local checkout=$2
  if [[ -n "${SYNC_REWRITE_APP_URL:-}" ]]; then
    _sync_rewrite_args+=(--app-url="$SYNC_REWRITE_APP_URL")
  fi
  if [[ -n "${SYNC_REWRITE_URL_MAP:-}" ]]; then
    _sync_rewrite_args+=(--map="$SYNC_REWRITE_URL_MAP")
  fi
  _sync_rewrite_args+=(
    --deploy-env="${SHOPWARE_DEPLOY_ENV:-}"
    --sync-env="${SYNC_ENV:-}"
    --checkout-basename="$checkout"
  )
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    _sync_rewrite_args+=(--dry-run)
  fi
}

# Hard refuse rewrite on a live consumer. SYNC_ALLOW_LIVE_RESTORE=1 does NOT bypass this.
# Optional args override env (tests): $1=SYNC_ENV $2=SHOPWARE_DEPLOY_ENV $3=checkout basename $4=hostname
sync_rewrite_is_live_consumer() {
  local sync_lc deploy_lc base_lc host_lc
  sync_lc="$(printf '%s' "${1:-${SYNC_ENV:-}}" | tr '[:upper:]' '[:lower:]')"
  deploy_lc="$(printf '%s' "${2:-${SHOPWARE_DEPLOY_ENV:-}}" | tr '[:upper:]' '[:lower:]')"
  base_lc="$(printf '%s' "${3:-}" | tr '[:upper:]' '[:lower:]')"
  host_lc="$(printf '%s' "${4:-}" | tr '[:upper:]' '[:lower:]')"
  [[ "$sync_lc" == "live" ]] && return 0
  [[ "$deploy_lc" == "live" ]] && return 0
  [[ "$base_lc" == "live" ]] && return 0
  [[ "$host_lc" == "live" ]] && return 0
  return 1
}

sync_rewrite_assert_not_live() {
  local sync_env="${1:-${SYNC_ENV:-}}"
  local deploy_env="${2:-${SHOPWARE_DEPLOY_ENV:-}}"
  local checkout="${3:-}"
  local host="${4:-}"
  if sync_rewrite_is_live_consumer "$sync_env" "$deploy_env" "$checkout" "$host"; then
    printf 'ERROR: Refusing sales-channel domain rewrite on a live host (SYNC_ENV=%s, SHOPWARE_DEPLOY_ENV=%s). Unset SYNC_REWRITE_APP_URL / SYNC_REWRITE_URL_MAP. Rewrite is never allowed on live (SYNC_ALLOW_LIVE_RESTORE=1 does not bypass this).\n' \
      "${sync_env:-unset}" "${deploy_env:-unset}" >&2
    return 1
  fi
  return 0
}

maybe_rewrite_sales_channel_domains() {
  if ! sync_rewrite_requested; then
    return
  fi
  assert_not_live_rewrite
  if [[ "$WANT_DB" -ne 1 ]]; then
    log "SYNC_REWRITE_APP_URL / SYNC_REWRITE_URL_MAP set but db was skipped — not rewriting sales_channel_domain"
    return
  fi
  log "Opt-in sales_channel_domain rewrite via fyrst:sales-channel:rewrite-urls (sales channel domains only; media CDN / plugin configs / payment webhooks are not updated)"
  local -a rewrite_cmd=(
    "${COMPOSE[@]}"
    run --rm --pull never --entrypoint php
    web bin/console fyrst:sales-channel:rewrite-urls
  )
  sync_rewrite_append_console_args rewrite_cmd "$(basename "$COMPOSE_DIR")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN ${rewrite_cmd[*]}"
    return
  fi
  if ! "${rewrite_cmd[@]}"; then
    die "fyrst:sales-channel:rewrite-urls failed. composer update fyrst/shopware-cd so the command and FyrstShopwareCdBundle exist, then composer recipes:update fyrst/shopware-cd."
  fi
}
