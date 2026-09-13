#!/usr/bin/env bash
# shopware-cli project dump helpers. Sourced by deploy/sync-runtime.sh.
# Safe to source from tests (no side effects).
#
# Production Shopware app images (compose service `web`) do not ship
# shopware-cli. Sync/backup dumps run a one-shot container from this pinned
# official image, attached to the Compose network (hostname `mysql`) with the
# shop root mounted so `.env` / `.shopware-project.yml` are visible.
#
# Pin: ghcr.io/shopware/shopware-cli:0.18.4
#   Native dump (not mysqldump). Docs:
#   https://developer.shopware.com/docs/products/tools/cli/project-commands/mysql-dump.html
# Override with SYNC_SHOPWARE_CLI_IMAGE. Escape hatch: SYNC_DUMP_ENGINE=mysqldump

# Official CLI image used at CI build time; same registry as Shopware docs.
SYNC_DUMP_SHOPWARE_CLI_IMAGE_DEFAULT="ghcr.io/shopware/shopware-cli:0.18.4"

sync_dump_engine() {
  printf '%s' "${SYNC_DUMP_ENGINE:-shopware-cli}" | tr '[:upper:]' '[:lower:]'
}

sync_dump_image() {
  printf '%s\n' "${SYNC_SHOPWARE_CLI_IMAGE:-$SYNC_DUMP_SHOPWARE_CLI_IMAGE_DEFAULT}"
}

sync_dump_truthy() {
  case "${1:-}" in
    1 | true | TRUE | yes | YES | on | ON) return 0 ;;
    *) return 1 ;;
  esac
}

sync_dump_falsy() {
  case "${1:-}" in
    0 | false | FALSE | no | NO | off | OFF) return 0 ;;
    *) return 1 ;;
  esac
}

# --clean default ON (skip cart / messenger / log noise). SYNC_DUMP_CLEAN=0 opts out.
sync_dump_want_clean() {
  if sync_dump_falsy "${SYNC_DUMP_CLEAN:-1}"; then
    return 1
  fi
  return 0
}

# --anonymize default OFF (live→staging often wants real data). SYNC_DUMP_ANONYMIZE=1 opts in.
sync_dump_want_anonymize() {
  sync_dump_truthy "${SYNC_DUMP_ANONYMIZE:-0}"
}

# --quick default ON (large DBs; same idea as mysqldump --quick). SYNC_DUMP_QUICK=0 opts out.
sync_dump_want_quick() {
  if sync_dump_falsy "${SYNC_DUMP_QUICK:-1}"; then
    return 1
  fi
  return 0
}

sync_dump_engine_is_mysqldump() {
  case "$(sync_dump_engine)" in
    mysqldump | mariadb-dump) return 0 ;;
    *) return 1 ;;
  esac
}

sync_dump_engine_is_shopware_cli() {
  case "$(sync_dump_engine)" in
    shopware-cli | "") return 0 ;;
    *) return 1 ;;
  esac
}

# Append `shopware-cli project dump` argv (no connection secrets, no --output) onto the named array.
# $1: nameref of an existing array
sync_dump_append_core_flags() {
  local -n _sync_dump_core=$1
  _sync_dump_core+=(
    --no-update-hint
    project
    dump
    --skip-lock-tables
    --compression=gzip
  )
  if sync_dump_want_quick; then
    _sync_dump_core+=(--quick)
  fi
  if sync_dump_want_clean; then
    _sync_dump_core+=(--clean)
  fi
  if sync_dump_want_anonymize; then
    _sync_dump_core+=(--anonymize)
  fi
}

# Append dump argv including --output. $1 = array name, $2 = output path or -
sync_dump_append_project_flags() {
  local __sync_dump_arr=$1
  local output=$2
  sync_dump_append_core_flags "$__sync_dump_arr"
  local -n _sync_dump_flags=$__sync_dump_arr
  _sync_dump_flags+=(--output="$output")
}

# Space-joined dump flags for logs (no credentials). $1 = output path or -
sync_dump_flags_log() {
  local output=$1
  local -a flags=()
  sync_dump_append_project_flags flags "$output"
  printf '%s' "${flags[*]}"
}

sync_dump_fail_hint() {
  local img
  img="$(sync_dump_image)"
  cat <<EOF
shopware-cli project dump could not run (image missing, pull failed, or docker run failed).
Pinned image: ${img}
The Shopware app image (compose service web) does not ship shopware-cli. Dumps use a
one-shot container from the official CLI image, attached to the Compose network
(hostname mysql) with the shop root mounted for .env / .shopware-project.yml.

  docker pull ${img}

Override the pin with SYNC_SHOPWARE_CLI_IMAGE=<registry/image:tag>.
Docs:
  https://developer.shopware.com/docs/products/tools/cli/installation.html
  https://developer.shopware.com/docs/products/tools/cli/project-commands/mysql-dump.html
This path does not silently fall back to mysqldump. Escape hatch: SYNC_DUMP_ENGINE=mysqldump
EOF
}
