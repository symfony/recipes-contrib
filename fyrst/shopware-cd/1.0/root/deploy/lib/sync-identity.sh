#!/usr/bin/env bash
# Sync-specific identity derive (SYNC_DATA_ROOT, compose project fallback).
# Sourced by deploy/sync-runtime.sh. Safe to source from tests.

require_shop_id() {
  if [[ -z "${SHOPWARE_SHOP_ID:-}" ]]; then
    die "SHOPWARE_SHOP_ID is required on the VPS (stable shop slug, same on live + staging + laptop). Set it in shop-root .env."
  fi
}

derived_data_root() {
  identity_derived_data_root "$1" "$2"
}

source_env_for_remote() {
  if [[ -n "${SYNC_SOURCE_ENV:-}" ]]; then
    printf '%s\n' "$SYNC_SOURCE_ENV"
  elif [[ -n "${FROM_LC:-}" && "$FROM_LC" != "local" && "$FROM_LC" != "this" ]]; then
    printf '%s\n' "$FROM_LC"
  else
    printf '%s\n' "live"
  fi
}

derive_local_data_root() {
  if [[ -n "${PRESET_SYNC_DATA_ROOT:-}" ]]; then
    DATA_ROOT=$PRESET_SYNC_DATA_ROOT
    return
  fi
  if [[ -n "${SYNC_DATA_ROOT:-}" ]]; then
    DATA_ROOT=$SYNC_DATA_ROOT
    return
  fi
  if [[ -n "${SHOPWARE_DATA_ROOT:-}" ]]; then
    DATA_ROOT=$SHOPWARE_DATA_ROOT
    return
  fi
  require_shop_id
  if [[ -z "${SHOPWARE_DEPLOY_ENV:-}" ]]; then
    die "SHOPWARE_DEPLOY_ENV is required to derive SHOPWARE_DATA_ROOT (live|staging|playground|dev). Set it in .env, or set SHOPWARE_DATA_ROOT / SYNC_DATA_ROOT explicitly."
  fi
  DATA_ROOT="$(derived_data_root "$SHOPWARE_SHOP_ID" "$SHOPWARE_DEPLOY_ENV")"
  SHOPWARE_DATA_ROOT=$DATA_ROOT
  export SHOPWARE_DATA_ROOT
  log "SHOPWARE_DATA_ROOT unset; derived ${DATA_ROOT}"
}

derive_compose_project_name() {
  if [[ -n "${COMPOSE_PROJECT_NAME:-}" ]]; then
    PROJECT_NAME=$COMPOSE_PROJECT_NAME
    export COMPOSE_PROJECT_NAME
    if [[ -n "${SHOPWARE_SHOP_ID:-}" && -n "${SHOPWARE_DEPLOY_ENV:-}" ]]; then
      local derived_project
      derived_project="$(identity_derived_project_name "$SHOPWARE_SHOP_ID" "$SHOPWARE_DEPLOY_ENV")"
      if [[ "$COMPOSE_PROJECT_NAME" != "$derived_project" ]]; then
        log "WARNING: COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} is set and overrides Compose name: (${derived_project}). shopware-cli project create writes COMPOSE_PROJECT_NAME=sw-shop-… into .env for local project dev. On the VPS, remove or comment out that line. This script does not delete it."
      fi
    fi
    return
  fi
  if [[ -n "${SHOPWARE_SHOP_ID:-}" && -n "${SHOPWARE_DEPLOY_ENV:-}" ]]; then
    COMPOSE_PROJECT_NAME="$(identity_derived_project_name "$SHOPWARE_SHOP_ID" "$SHOPWARE_DEPLOY_ENV")"
    PROJECT_NAME=$COMPOSE_PROJECT_NAME
    export COMPOSE_PROJECT_NAME
    log "COMPOSE_PROJECT_NAME unset; derived ${COMPOSE_PROJECT_NAME}"
    return
  fi
  local n=""
  n="$("${COMPOSE[@]}" config 2>/dev/null | awk '/^name:/{print $2; exit}' || true)"
  n="$(printf '%s' "$n" | tr -d '\r' | tr -d '"')"
  if [[ -n "$n" ]]; then
    PROJECT_NAME=$n
    COMPOSE_PROJECT_NAME=$n
    export COMPOSE_PROJECT_NAME
    return
  fi
  die "Set COMPOSE_PROJECT_NAME in .env (must be unique on this Docker host), or set SHOPWARE_SHOP_ID and SHOPWARE_DEPLOY_ENV to derive \${SHOPWARE_SHOP_ID}-\${SHOPWARE_DEPLOY_ENV}."
}

resolve_project_name() {
  derive_compose_project_name
}

resolve_remote_project_name() {
  local n=""
  n="$(remote_bash "${COMPOSE_STR} config 2>/dev/null | awk '/^name:/{print \$2; exit}'" || true)"
  n="$(printf '%s' "$n" | tr -d '\r' | tr -d '"' | tail -n 1)"
  if [[ -n "$n" ]]; then
    PROJECT_NAME=$n
  else
    resolve_project_name
  fi
}
