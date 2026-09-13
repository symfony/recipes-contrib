#!/usr/bin/env bash
# Shared Compose file list + command array for VPS / sync scripts.
# Sourced by deploy/lib/vps-common.sh and deploy/sync-runtime.sh.
# Safe to source from tests (no side effects). Caller must cd to shop root.

COMPOSE_FILES=(
  deploy/compose.yaml
  deploy/compose.prod.yaml
  deploy/compose.vps.yaml
)

# Shop root; callers set this before compose_init (sync_cli_defaults / vps_cd_shop_root).
: "${COMPOSE_DIR:=}"

# Alias kept for vps-common / existing callers.
VPS_COMPOSE_FILES=("${COMPOSE_FILES[@]}")
COMPOSE=()
COMPOSE_STR=""

compose_fail() {
  if declare -F die >/dev/null 2>&1; then
    die "$@"
  elif declare -F vps_die >/dev/null 2>&1; then
    vps_die "$@"
  else
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
  fi
}

compose_require_files() {
  local f
  for f in "${COMPOSE_FILES[@]}"; do
    if [[ ! -f "$f" ]]; then
      compose_fail "Missing ${f} (expected under shop root COMPOSE_DIR=${COMPOSE_DIR})"
    fi
  done
}

compose_set_cmd() {
  COMPOSE=(
    docker compose
    --env-file .env
    -f deploy/compose.yaml
    -f deploy/compose.prod.yaml
    -f deploy/compose.vps.yaml
  )
  COMPOSE_STR="docker compose --env-file .env -f deploy/compose.yaml -f deploy/compose.prod.yaml -f deploy/compose.vps.yaml"
}

compose_init() {
  compose_require_files
  compose_set_cmd
}

has_mysql_service_local() {
  "${COMPOSE[@]}" config --services 2>/dev/null | grep -qx mysql
}

ensure_image_for_compose() {
  if [[ -z "${IMAGE:-}" ]]; then
    compose_fail "IMAGE is empty. Set it in shop-root .env (same value deploy/vps-release.sh uses). Sync does not invoke vps-release.sh."
  fi
}
