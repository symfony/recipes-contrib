#!/usr/bin/env bash
# Pull live VPS SHOPWARE_DATA_ROOT trees into local `shopware-cli project dev` paths.
#
# Local CLI compose bind-mounts the whole project, so destinations are the shop
# tree (files/, public/media/, …) — not VPS /var/lib/shopware/data/<shop>/<env>.
# VPS → VPS copy stays deploy/sync-runtime.sh on the consumer.
#
# Remote default (when unset / unprobed):
#   /var/lib/shopware/data/${SHOPWARE_SHOP_ID}/${--from env}
# Laptop .env needs at least SHOPWARE_SHOP_ID (same as live).
#
#   bash deploy/sync-runtime-local.sh --from live --data all
#   bash deploy/sync-runtime-local.sh --from live --data all --delete --dry-run
#
# Do not run with `bash -x` — SSH identities / env may be sensitive.

set -euo pipefail

case "$-" in
  *x*)
    printf 'ERROR: refusing to run with xtrace (credentials may be in the environment)\n' >&2
    exit 1
    ;;
esac

umask 077

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_DIR="${COMPOSE_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

DEFAULT_DATA="files,media,thumbnail,theme,sitemap"
SHOPWARE_DATA_BASE="${SHOPWARE_DATA_BASE:-/var/lib/shopware/data}"

FROM=""
DATA_SPEC="all"
DRY_RUN=0
DELETE=0

SSH_TARGET=""
REMOTE_PATH=""
REMOTE_DATA_ROOT=""
WANT_VOLUMES=()

log() { printf '==> %s\n' "$*"; }
err() { printf 'ERROR: %s\n' "$*" >&2; }
die() { err "$@"; exit 1; }

usage() {
  cat <<'EOF'
Usage: deploy/sync-runtime-local.sh --from <alias> [options]

Copy bind-mounted Shopware runtime files from a VPS (typically live) into
this shop checkout for `shopware-cli project dev`.

  live $SHOPWARE_DATA_ROOT/files       →  ./files/
  live $SHOPWARE_DATA_ROOT/media       →  ./public/media/
  live $SHOPWARE_DATA_ROOT/thumbnail   →  ./public/thumbnail/
  live $SHOPWARE_DATA_ROOT/theme       →  ./public/theme/
  live $SHOPWARE_DATA_ROOT/sitemap     →  ./public/sitemap/

Remote SHOPWARE_DATA_ROOT defaults to
/var/lib/shopware/data/${SHOPWARE_SHOP_ID}/<from-env> (usually live).
Set SHOPWARE_SHOP_ID in laptop .env (same slug as the VPS).

This is not deploy/sync-runtime.sh (that script targets VPS SHOPWARE_DATA_ROOT
+ deploy Compose). Database dumps are out of scope here.

Options:
  --from <alias>         SSH source (required). Default host is the alias
                        itself (e.g. Host live in ~/.ssh/config).
  --data <list>|all     Comma-separated subset, or "all" (default).
                        Items: files, media, thumbnail, theme, sitemap
  --delete              Pass rsync --delete (drops local-only files)
  --dry-run             Print planned rsyncs; do not connect or copy
  -h, --help

Environment (optional; deploy/sync.env is sourced when present):
  SYNC_SSH_HOST          Source hostname (default: the --from alias)
  SYNC_SSH_USER          SSH user (empty = ssh config / current user)
  SYNC_SSH_PORT          SSH port (default 22)
  SYNC_SSH_KEY           Identity file (SYNC_SSH_IDENTITY also accepted)
  SYNC_REMOTE_PATH       Shop checkout on the source (optional; used to
                        probe SHOPWARE_DATA_ROOT from the remote .env).
                        SYNC_SSH_PATH / SYNC_LIVE_PATH also accepted.
  SYNC_REMOTE_DATA_ROOT  Bind-mount root on the source (overrides derivation)
  SHOPWARE_SHOP_ID       Same slug as live; used to derive the remote root
  SHOPWARE_DATA_ROOT     Unused as a local destination (project-dev paths)

Per-alias overrides (example --from live): SYNC_LIVE_SSH_HOST,
SYNC_LIVE_SSH_USER, SYNC_LIVE_SSH_PORT, SYNC_LIVE_SSH_KEY,
SYNC_LIVE_REMOTE_PATH, SYNC_LIVE_DATA_ROOT.

Examples:
  bash deploy/sync-runtime-local.sh --from live --data all
  bash deploy/sync-runtime-local.sh --from live --data media,files --delete
  bash deploy/sync-runtime-local.sh --from live --data all --dry-run

After copy:
  shopware-cli project console cache:clear
EOF
}

need_value() {
  local flag=$1
  local value=${2:-}
  if [[ -z "$value" || "$value" == --* ]]; then
    die "${flag} requires a value"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    sync)
      # Muscle memory from deploy/sync-runtime.sh; this script only pulls locally.
      shift
      ;;
    snapshot | restore | export)
      die "Use deploy/sync-runtime.sh ${1} on a VPS. This script only rsyncs into local project-dev paths."
      ;;
    help | -h | --help)
      usage
      exit 0
      ;;
    --from)
      need_value "$1" "${2:-}"
      FROM=$2
      shift 2
      ;;
    --from=*)
      FROM="${1#*=}"
      shift
      ;;
    --data)
      need_value "$1" "${2:-}"
      DATA_SPEC=$2
      shift 2
      ;;
    --data=*)
      DATA_SPEC="${1#*=}"
      shift
      ;;
    --delete)
      DELETE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -*)
      die "Unknown option: $1 (try --help)"
      ;;
    *)
      die "Unexpected argument: $1 (try --help)"
      ;;
  esac
done

if [[ -z "$FROM" ]]; then
  usage
  die "Missing --from <alias> (e.g. --from live)"
fi

cd "$COMPOSE_DIR"

load_env_file() {
  local f=$1
  if [[ -f "$f" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$f"
    set +a
  fi
}

load_env_file .env
load_env_file deploy/sync.env
SHOPWARE_DATA_BASE="${SHOPWARE_DATA_BASE:-/var/lib/shopware/data}"

derived_remote_data_root() {
  local shop="${SHOPWARE_SHOP_ID:-}"
  local envn="${1:-${FROM_LC:-live}}"
  if [[ -n "$shop" ]]; then
    printf '%s' "${SHOPWARE_DATA_BASE}/${shop}/${envn}"
  else
    printf '%s' "$SHOPWARE_DATA_BASE"
  fi
}

split_csv() {
  local csv=$1
  local IFS=','
  # shellcheck disable=SC2086
  set -- $csv
  local item
  for item in "$@"; do
    item="${item// /}"
    [[ -n "$item" ]] && printf '%s\n' "$item"
  done
}

normalize_data() {
  local spec=$1
  local item lower
  local -a raw=()

  if [[ "$spec" == "all" ]]; then
    spec=$DEFAULT_DATA
  fi

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    raw+=("$item")
  done < <(split_csv "$spec")

  if [[ ${#raw[@]} -eq 0 ]]; then
    die "--data is empty"
  fi

  WANT_VOLUMES=()
  for item in "${raw[@]}"; do
    lower=$(printf '%s' "$item" | tr '[:upper:]' '[:lower:]')
    case "$lower" in
      db | database | mysql)
        die "Database dumps are out of scope for sync-runtime-local.sh. Copy SQL separately into the CLI database service, or use deploy/sync-runtime.sh on a VPS."
        ;;
      files | media | thumbnail | theme | sitemap)
        WANT_VOLUMES+=("$lower")
        ;;
      mysql_data | redis_data | volumes)
        die "Unknown --data item '${item}'. Use files, media, thumbnail, theme, sitemap, or all."
        ;;
      *)
        die "Unknown --data item '${item}'. Use files, media, thumbnail, theme, sitemap, or all."
        ;;
    esac
  done

  if [[ ${#WANT_VOLUMES[@]} -eq 0 ]]; then
    die "Nothing to copy"
  fi
}

normalize_data "$DATA_SPEC"

lower_s() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

FROM_LC="$(lower_s "$FROM")"

if [[ "$FROM_LC" == "local" || "$FROM_LC" == "this" ]]; then
  die "--from local is invalid here. Source must be a VPS alias (e.g. --from live)."
fi

alias_key() {
  printf '%s' "$1" | tr '[:lower:]-' '[:upper:]_'
}

pick_alias_env() {
  local key=$1
  local suffix=$2
  local specific="SYNC_${key}_${suffix}"
  local general="SYNC_${suffix}"
  if [[ -n "${!specific:-}" ]]; then
    printf '%s' "${!specific}"
  else
    printf '%s' "${!general:-}"
  fi
}

key="$(alias_key "$FROM")"
host="$(pick_alias_env "$key" SSH_HOST)"
user="$(pick_alias_env "$key" SSH_USER)"
port="$(pick_alias_env "$key" SSH_PORT)"
keyfile="$(pick_alias_env "$key" SSH_KEY)"
if [[ -z "$keyfile" ]]; then
  keyfile="$(pick_alias_env "$key" SSH_IDENTITY)"
fi
REMOTE_PATH="$(pick_alias_env "$key" REMOTE_PATH)"
if [[ -z "$REMOTE_PATH" ]]; then
  REMOTE_PATH="$(pick_alias_env "$key" SSH_PATH)"
fi
if [[ -z "$REMOTE_PATH" ]]; then
  REMOTE_PATH="$(pick_alias_env "$key" PATH)"
fi
specific_dr="SYNC_${key}_DATA_ROOT"
REMOTE_DATA_ROOT="${!specific_dr:-${SYNC_REMOTE_DATA_ROOT:-}}"

if [[ -z "$host" ]]; then
  host=$FROM
fi
SYNC_SSH_HOST=$host
SYNC_SSH_USER=$user
SYNC_SSH_PORT="${port:-22}"
SYNC_SSH_KEY=$keyfile

if [[ -n "$SYNC_SSH_USER" ]]; then
  SSH_TARGET="${SYNC_SSH_USER}@${host}"
else
  SSH_TARGET=$host
fi

SSH_CMD=(ssh -o BatchMode=yes -p "${SYNC_SSH_PORT:-22}")
if [[ -n "${SYNC_SSH_KEY:-}" ]]; then
  SSH_CMD+=(-o IdentitiesOnly=yes -i "${SYNC_SSH_KEY}")
fi

local_item_dir() {
  local logical=$1
  case "$logical" in
    files) printf '%s/files\n' "$COMPOSE_DIR" ;;
    media) printf '%s/public/media\n' "$COMPOSE_DIR" ;;
    thumbnail) printf '%s/public/thumbnail\n' "$COMPOSE_DIR" ;;
    theme) printf '%s/public/theme\n' "$COMPOSE_DIR" ;;
    sitemap) printf '%s/public/sitemap\n' "$COMPOSE_DIR" ;;
    *) die "No local project-dev path for ${logical}" ;;
  esac
}

bind_item_dir() {
  local root=$1
  local logical=$2
  printf '%s/%s\n' "$root" "$logical"
}

require_cmd() {
  local c=$1
  if ! command -v "$c" >/dev/null 2>&1; then
    die "Missing command '${c}'. Install rsync and OpenSSH client on this machine."
  fi
}

if [[ -n "${SYNC_SSH_KEY:-}" && ! -f "${SYNC_SSH_KEY}" ]]; then
  die "SYNC_SSH_KEY not found: ${SYNC_SSH_KEY}"
fi

require_cmd bash
if [[ "$DRY_RUN" -eq 0 ]]; then
  require_cmd ssh
  require_cmd rsync
fi

remote_bash() {
  local cmd=$1
  local remote_cmd
  if [[ -n "${REMOTE_PATH}" ]]; then
    remote_cmd="set -euo pipefail; cd $(printf '%q' "$REMOTE_PATH"); if [ -f .env ]; then set -a; . ./.env; set +a; fi; ${cmd}"
  else
    remote_cmd="set -euo pipefail; ${cmd}"
  fi
  "${SSH_CMD[@]}" "$SSH_TARGET" "$remote_cmd"
}

resolve_remote_data_root() {
  if [[ -n "${REMOTE_DATA_ROOT}" ]]; then
    return
  fi
  local fallback
  fallback="$(derived_remote_data_root "$FROM_LC")"
  if [[ -z "${SHOPWARE_SHOP_ID:-}" && -z "${REMOTE_DATA_ROOT}" ]]; then
    log "SHOPWARE_SHOP_ID unset; remote root fallback ${fallback}. Set SHOPWARE_SHOP_ID in .env (same as live)."
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    REMOTE_DATA_ROOT=$fallback
    log "DRY-RUN remote SHOPWARE_DATA_ROOT default ${REMOTE_DATA_ROOT} (probe skipped)"
    return
  fi
  local probed="" remote_printf
  if [[ -n "${REMOTE_PATH}" ]]; then
    # shellcheck disable=SC2016
    remote_printf='printf %s "${SYNC_DATA_ROOT:-${SHOPWARE_DATA_ROOT:-}}"'
    probed="$(remote_bash "$remote_printf" || true)"
    probed="$(printf '%s' "$probed" | tr -d '\r' | tail -n 1)"
  fi
  if [[ -n "$probed" ]]; then
    REMOTE_DATA_ROOT=$probed
  else
    REMOTE_DATA_ROOT=$fallback
  fi
  log "Remote bind-mount root: ${REMOTE_DATA_ROOT}"
}

rsync_from_remote_tree() {
  local remote_dir=$1
  local dest=$2
  local -a args
  args=(-az --no-owner --no-group -e "${SSH_CMD[*]}")
  if [[ "$DELETE" -eq 1 ]]; then
    args+=(--delete)
  fi
  mkdir -p "$dest"
  rsync "${args[@]}" "${SSH_TARGET}:${remote_dir%/}/" "${dest%/}/"
}

sync_item() {
  local logical=$1
  local src dest
  src="$(bind_item_dir "$REMOTE_DATA_ROOT" "$logical")"
  dest="$(local_item_dir "$logical")"
  log "Rsync ${SSH_TARGET}:${src}/ → ${dest}/"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ "$DELETE" -eq 1 ]]; then
      log "DRY-RUN rsync -az --delete ${SSH_TARGET}:${src}/ ${dest}/"
    else
      log "DRY-RUN rsync -az ${SSH_TARGET}:${src}/ ${dest}/"
    fi
    return
  fi
  rsync_from_remote_tree "$src" "$dest"
}

resolve_remote_data_root

log "Local project-dev pull  from=${FROM}  data=$(IFS=,; printf '%s' "${WANT_VOLUMES[*]}")  delete=${DELETE}  dry-run=${DRY_RUN}"

item=""
for item in "${WANT_VOLUMES[@]}"; do
  sync_item "$item"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "Dry-run finished (no files copied)"
  exit 0
fi

log "Copy finished ${FROM} → ${COMPOSE_DIR} (project-dev paths)"
log "Next: shopware-cli project console cache:clear"
log "These dirs stay gitignored — never commit them."
