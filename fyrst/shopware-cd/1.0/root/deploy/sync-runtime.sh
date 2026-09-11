#!/usr/bin/env bash
# VPS runtime data: mysqldump + rsync of bind-mounted host dirs over SSH. No S3.
#
# Commands: sync | snapshot | restore
# Direction for sync: higher env → this host (live → staging / playground / dev).
# Never auto-pushes into live.
#
# Shopware files live on the host under
# ${SHOPWARE_DATA_BASE:-/var/lib/shopware/data}/${SHOPWARE_SHOP_ID}/${SHOPWARE_DEPLOY_ENV}/{files,media,thumbnail,theme,sitemap}
# (compose bind mounts). Optional SHOPWARE_DATA_ROOT is derived when unset.
# mysql_data / redis_data stay named volumes and are not copied here (DB is mysqldump).
#
# Copy deploy/sync.env.example → deploy/sync.env on the consumer and fill SYNC_SSH_*.
#
#   bash deploy/sync-runtime.sh sync --from live --data all
#   bash deploy/sync-runtime.sh snapshot --data all
#   bash deploy/sync-runtime.sh restore --snapshot <id> --data all
#
# Plumbing (used over SSH on the source; stdout is the payload):
#   bash deploy/sync-runtime.sh export --data db
#   bash deploy/sync-runtime.sh export --data volumes --volume media

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: deploy/sync-runtime.sh <command> [options]

Commands:
  sync       Pull DB + bind-mount dirs from a higher env onto this host
  snapshot   Write a local snapshot (mysqldump + rsync of host dirs)
  restore    Restore a local snapshot onto this host
  export     Plumbing: write a dump/tar to stdout (SSH fallback)

Options:
  --from <env>       Source env for sync (e.g. live)
  --data <what>      all | db | volumes   (default: all)
  --volume <name>    Single bind-mount dir (files|media|thumbnail|theme|sitemap)
  --snapshot <id>    Snapshot id for restore (directory name under SYNC_SNAPSHOT_DIR)
  --yes              Do not prompt
  -h, --help

Examples:
  bash deploy/sync-runtime.sh sync --from live --data all
  bash deploy/sync-runtime.sh snapshot --data all
  bash deploy/sync-runtime.sh restore --snapshot 20260911T021500Z-live --data all

No S3. Files stay on the VPS (rsync over SSH, or a local snapshot dir). Live
is never the destination of `sync`. Cron on the lower env (see
deploy/README.md and deploy/sync-runtime.md).
EOF
}

log() { printf '==> %s\n' "$*" >&2; }
die() { printf '%s\n' "$*" >&2; exit 1; }

COMMAND=""
FROM_ENV=""
DATA="all"
VOLUME_KEY=""
SNAPSHOT_ID=""
YES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    sync|snapshot|restore|export)
      [[ -z "$COMMAND" ]] || die "Multiple commands: $COMMAND and $1"
      COMMAND="$1"
      shift
      ;;
    --from)
      FROM_ENV="${2:-}"
      [[ -n "$FROM_ENV" ]] || die "--from requires an env name"
      shift 2
      ;;
    --data)
      DATA="${2:-}"
      [[ -n "$DATA" ]] || die "--data requires all|db|volumes"
      shift 2
      ;;
    --volume)
      VOLUME_KEY="${2:-}"
      [[ -n "$VOLUME_KEY" ]] || die "--volume requires a bind-mount dir name (files|media|thumbnail|theme|sitemap)"
      shift 2
      ;;
    --snapshot)
      SNAPSHOT_ID="${2:-}"
      [[ -n "$SNAPSHOT_ID" ]] || die "--snapshot requires an id"
      shift 2
      ;;
    --yes|-y)
      YES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$COMMAND" ]] || { usage >&2; exit 1; }

case "$DATA" in
  all|db|volumes) ;;
  *) die "--data must be all, db, or volumes (got: $DATA)" ;;
esac

want_db() { [[ "$DATA" == all || "$DATA" == db ]]; }
want_volumes() { [[ "$DATA" == all || "$DATA" == volumes ]]; }

ensure_data_root() {
  if want_volumes && [[ -z "${SHOPWARE_DATA_ROOT:-}" ]]; then
    die "Set SHOPWARE_DATA_ROOT or SHOPWARE_SHOP_ID+SHOPWARE_DEPLOY_ENV in .env"
  fi
}

COMPOSE_DIR="${COMPOSE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$COMPOSE_DIR"

CI_IMAGE="${IMAGE:-}"
CI_IMAGE_TAG="${IMAGE_TAG:-}"
CI_PROFILES="${COMPOSE_PROFILES:-}"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi
if [[ -f .env.prod ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.prod
  set +a
fi

IMAGE="${CI_IMAGE:-${IMAGE:-}}"
IMAGE_TAG="${CI_IMAGE_TAG:-${IMAGE_TAG:-}}"
COMPOSE_PROFILES="${CI_PROFILES:-${COMPOSE_PROFILES:-}}"
export IMAGE IMAGE_TAG

SYNC_ENV_FILE="${SYNC_ENV_FILE:-$COMPOSE_DIR/deploy/sync.env}"
if [[ -f "$SYNC_ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$SYNC_ENV_FILE"
  set +a
fi

SHOPWARE_DATA_BASE="${SHOPWARE_DATA_BASE:-/var/lib/shopware/data}"

# SHOPWARE_SHOP_ID + SHOPWARE_DEPLOY_ENV (or SYNC_ENV) → project name / data root.
# Compose interpolates those two (+ optional SHOPWARE_DATA_BASE) itself.
# Scripts fill COMPOSE_PROJECT_NAME / SHOPWARE_DATA_ROOT when they are empty.
if [[ -z "${SHOPWARE_DEPLOY_ENV:-}" && -n "${SYNC_ENV:-}" ]]; then
  SHOPWARE_DEPLOY_ENV="${SYNC_ENV}"
fi
if [[ -z "${SYNC_ENV:-}" && -n "${SHOPWARE_DEPLOY_ENV:-}" ]]; then
  SYNC_ENV="${SHOPWARE_DEPLOY_ENV}"
fi
if [[ -z "${COMPOSE_PROJECT_NAME:-}" && -n "${SHOPWARE_SHOP_ID:-}" && -n "${SHOPWARE_DEPLOY_ENV:-}" ]]; then
  COMPOSE_PROJECT_NAME="${SHOPWARE_SHOP_ID}-${SHOPWARE_DEPLOY_ENV}"
fi
if [[ -z "${SHOPWARE_DATA_ROOT:-}" && -n "${SHOPWARE_SHOP_ID:-}" && -n "${SHOPWARE_DEPLOY_ENV:-}" ]]; then
  SHOPWARE_DATA_ROOT="${SHOPWARE_DATA_BASE}/${SHOPWARE_SHOP_ID}/${SHOPWARE_DEPLOY_ENV}"
fi
if [[ -n "${COMPOSE_PROJECT_NAME:-}" ]]; then
  export COMPOSE_PROJECT_NAME
fi
if [[ -n "${SHOPWARE_DATA_ROOT:-}" ]]; then
  export SHOPWARE_DATA_ROOT
fi

SYNC_COMPOSE_PROJECT="${SYNC_COMPOSE_PROJECT:-${COMPOSE_PROJECT_NAME:-}}"
SYNC_VOLUMES="${SYNC_VOLUMES:-files,media,thumbnail,theme,sitemap}"
SYNC_SNAPSHOT_DIR="${SYNC_SNAPSHOT_DIR:-$COMPOSE_DIR/.runtime-snapshots}"
SYNC_KEEP_SNAPSHOTS="${SYNC_KEEP_SNAPSHOTS:-5}"
SYNC_SSH_PORT="${SYNC_SSH_PORT:-22}"

if [[ "$COMMAND" != "export" && -n "${COMPOSE_PROJECT_NAME:-}${SHOPWARE_DATA_ROOT:-}" ]]; then
  log "Identity shop=${SHOPWARE_SHOP_ID:-?} env=${SHOPWARE_DEPLOY_ENV:-?} project=${COMPOSE_PROJECT_NAME:-?} data_root=${SHOPWARE_DATA_ROOT:-?}"
fi

COMPOSE=(
  docker compose
  --project-directory "$COMPOSE_DIR"
  -f deploy/compose.yaml
  -f deploy/compose.prod.yaml
  -f deploy/compose.vps.yaml
)

PROFILE_ARGS=()
IFS=',' read -ra RAW_PROFILES <<< "${COMPOSE_PROFILES:-}"
for p in "${RAW_PROFILES[@]}"; do
  p="${p// /}"
  if [[ -z "$p" ]]; then
    continue
  fi
  if [[ "$p" == "setup" ]]; then
    continue
  fi
  PROFILE_ARGS+=(--profile "$p")
done

has_service() {
  "${COMPOSE[@]}" "${PROFILE_ARGS[@]}" config --services 2>/dev/null | grep -qx "$1"
}

project_name() {
  local n
  n="$("${COMPOSE[@]}" config 2>/dev/null | sed -n 's/^name:[[:space:]]*//p' | head -n1 || true)"
  n="${n:-$SYNC_COMPOSE_PROJECT}"
  n="${n:-$COMPOSE_PROJECT_NAME}"
  [[ -n "$n" ]] || die "Set COMPOSE_PROJECT_NAME in .env (e.g. \${SHOPWARE_SHOP_ID}-\${SHOPWARE_DEPLOY_ENV})"
  printf '%s\n' "$n"
}

volume_list() {
  local raw="$SYNC_VOLUMES" item
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    item="${item// /}"
    [[ -n "$item" ]] && printf '%s\n' "$item"
  done
}

host_data_dir() {
  printf '%s/%s\n' "$SHOPWARE_DATA_ROOT" "$1"
}

docker_volume_name() {
  printf '%s_%s\n' "$(project_name)" "$1"
}

has_named_volume() {
  docker volume inspect "$(docker_volume_name "$1")" >/dev/null 2>&1
}

env_rank() {
  case "$1" in
    live|prod|production) echo 0 ;;
    staging|stage) echo 1 ;;
    playground|preview) echo 2 ;;
    dev|local|development) echo 3 ;;
    *) echo 10 ;;
  esac
}

is_live_env() {
  case "$1" in
    live|prod|production) return 0 ;;
    *) return 1 ;;
  esac
}

confirm() {
  local msg="$1"
  if [[ "$YES" -eq 1 || "${SYNC_ASSUME_YES:-0}" == 1 ]]; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    log "$msg (non-interactive; continuing)"
    return 0
  fi
  local ans
  read -r -p "$msg [y/N] " ans
  [[ "$ans" == y || "$ans" == Y || "$ans" == yes ]]
}

acquire_lock() {
  local lock="/tmp/shopware-sync-runtime-${COMPOSE_PROJECT_NAME:-default}.lock"
  if command -v flock >/dev/null 2>&1; then
    exec 9>"$lock"
    if ! flock -n 9; then
      die "Another sync-runtime.sh is running ($lock)"
    fi
  fi
}

urldecode() {
  local s="${1//+/ }"
  printf '%b' "${s//%/\\x}"
}

# Sets DB_USER DB_PASS DB_HOST DB_PORT DB_NAME from DATABASE_URL (mysql://).
parse_database_url() {
  local url="${DATABASE_URL:-}"
  [[ -n "$url" ]] || die "DATABASE_URL is empty"
  url="${url#mysql://}"
  url="${url#mysqli://}"
  url="${url%%\?*}"
  local cred hostpart
  cred="${url%%@*}"
  hostpart="${url#*@}"
  if [[ "$url" == "$cred" ]]; then
    die "DATABASE_URL must look like mysql://USER:PASSWORD@HOST:3306/DATABASE"
  fi
  DB_USER="${cred%%:*}"
  if [[ "$cred" == *:* ]]; then
    DB_PASS="$(urldecode "${cred#*:}")"
  else
    DB_PASS=""
  fi
  DB_NAME="${hostpart#*/}"
  DB_NAME="${DB_NAME%%/*}"
  hostpart="${hostpart%%/*}"
  if [[ "$hostpart" == \[* ]]; then
    DB_HOST="${hostpart#\[}"
    DB_HOST="${DB_HOST%%]*}"
    DB_PORT="${hostpart##*]:}"
    [[ "$DB_PORT" == "$hostpart" ]] && DB_PORT=3306
  elif [[ "$hostpart" == *:* ]]; then
    DB_HOST="${hostpart%%:*}"
    DB_PORT="${hostpart##*:}"
  else
    DB_HOST="$hostpart"
    DB_PORT=3306
  fi
}

wait_mysql() {
  local i
  for i in $(seq 1 60); do
    if "${COMPOSE[@]}" exec -T mysql mysqladmin ping -h 127.0.0.1 --silent >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  die "mysql did not become ready"
}

ensure_mysql_up() {
  if has_service mysql; then
    log "Starting mysql"
    "${COMPOSE[@]}" up -d --no-build mysql
    wait_mysql
  fi
}

# Dump SQL to stdout. Logs go to stderr.
dump_sql() {
  if has_service mysql; then
    ensure_mysql_up
    : "${MYSQL_DATABASE:?Set MYSQL_DATABASE}"
    : "${MYSQL_ROOT_PASSWORD:?Set MYSQL_ROOT_PASSWORD}"
    "${COMPOSE[@]}" exec -T \
      -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" \
      mysql \
      mysqldump \
      -uroot \
      --single-transaction \
      --quick \
      --routines \
      --triggers \
      --no-tablespaces \
      --default-character-set=utf8mb4 \
      "$MYSQL_DATABASE"
    return
  fi
  parse_database_url
  docker run --rm --network host \
    -e MYSQL_PWD="$DB_PASS" \
    mysql:8.4 \
    mysqldump \
    -h"$DB_HOST" \
    -P"$DB_PORT" \
    -u"$DB_USER" \
    --single-transaction \
    --quick \
    --routines \
    --triggers \
    --no-tablespaces \
    --default-character-set=utf8mb4 \
    "$DB_NAME"
}

import_sql() {
  if has_service mysql; then
    ensure_mysql_up
    : "${MYSQL_DATABASE:?Set MYSQL_DATABASE}"
    : "${MYSQL_ROOT_PASSWORD:?Set MYSQL_ROOT_PASSWORD}"
    "${COMPOSE[@]}" exec -T \
      -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" \
      mysql \
      mysql \
      -uroot \
      --default-character-set=utf8mb4 \
      --max-allowed-packet=512M \
      "$MYSQL_DATABASE"
    return
  fi
  parse_database_url
  docker run --rm -i --network host \
    -e MYSQL_PWD="$DB_PASS" \
    mysql:8.4 \
    mysql \
    -h"$DB_HOST" \
    -P"$DB_PORT" \
    -u"$DB_USER" \
    --default-character-set=utf8mb4 \
    --max-allowed-packet=512M \
    "$DB_NAME"
}

rewrite_urls() {
  local from="${SYNC_REWRITE_FROM_URL:-}" to="${SYNC_REWRITE_TO_URL:-}"
  [[ -n "$from" && -n "$to" ]] || return 0
  log "Rewriting sales_channel_domain URLs: $from → $to"
  local sql
  sql=$(printf "UPDATE sales_channel_domain SET url = REPLACE(url, '%s', '%s');\n" \
    "${from//\'/\'\'}" "${to//\'/\'\'}")
  printf '%s' "$sql" | import_sql
}

# Primary: tar/rsync the bind-mounted host dir. Fallback: named Docker volume.
dump_volume_tar() {
  local key="$1" host vol
  host="$(host_data_dir "$key")"
  if [[ -d "$host" ]]; then
    tar -C "$host" -czf - .
    return
  fi
  vol="$(docker_volume_name "$key")"
  if has_named_volume "$key"; then
    log "Bind-mount dir $host missing; archiving named volume $vol"
    docker run --rm \
      -v "$vol":/volume:ro \
      alpine:3.20 \
      tar -C /volume -czf - .
    return
  fi
  die "No bind-mount dir ($host) and no Docker volume $vol for $key"
}

rsync_local_dir() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$src/" "$dest/"
    return
  fi
  find "$dest" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  tar -C "$src" -cf - . | tar -C "$dest" -xf -
}

restore_host_tar_stdin() {
  local dest
  dest="$(host_data_dir "$1")"
  mkdir -p "$dest"
  find "$dest" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  tar -C "$dest" -xzf -
}

snapshot_runtime_dir() {
  local key="$1" dest="$2/$key" host
  host="$(host_data_dir "$key")"
  if [[ -d "$host" ]]; then
    log "Rsync $host → $dest"
    rsync_local_dir "$host" "$dest"
    return
  fi
  if has_named_volume "$key"; then
    log "Archiving named volume $key → $2/${key}.tar.gz"
    dump_volume_tar "$key" >"$2/${key}.tar.gz"
    return
  fi
  log "Skip $key (no host dir $host)"
}

restore_runtime_dir() {
  local key="$1" dir="$2" dest
  dest="$(host_data_dir "$key")"
  mkdir -p "$dest"
  if [[ -d "$dir/$key" ]]; then
    log "Rsync snapshot $key → $dest"
    rsync_local_dir "$dir/$key" "$dest"
    return
  fi
  if [[ -f "$dir/${key}.tar.gz" ]]; then
    log "Extracting $key tar → $dest"
    find "$dest" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    tar -C "$dest" -xzf "$dir/${key}.tar.gz"
    return
  fi
  log "Skip $key (not in snapshot)"
}

stop_app() {
  local svcs=()
  has_service web && svcs+=(web)
  has_service worker && svcs+=(worker)
  has_service scheduler && svcs+=(scheduler)
  if [[ ${#svcs[@]} -gt 0 ]]; then
    log "Stopping ${svcs[*]}"
    "${COMPOSE[@]}" "${PROFILE_ARGS[@]}" stop "${svcs[@]}" || true
  fi
}

start_app() {
  log "Starting web"
  "${COMPOSE[@]}" up -d --no-build --remove-orphans web
  if [[ ${#PROFILE_ARGS[@]} -gt 0 ]]; then
    "${COMPOSE[@]}" "${PROFILE_ARGS[@]}" up -d --no-build
  fi
}

chown_volumes() {
  local key dest
  while IFS= read -r key; do
    dest="$(host_data_dir "$key")"
    mkdir -p "$dest"
    log "chown 82:82 $dest"
    docker run --rm \
      -v "$dest":/data \
      alpine:3.20 \
      chown -R 82:82 /data
  done < <(volume_list)
}

cache_clear() {
  if ! has_service web; then
    return 0
  fi
  log "cache:clear"
  "${COMPOSE[@]}" exec -T web php bin/console cache:clear || log "cache:clear failed (continuing)"
}

env_upper() {
  printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}

snapshot_ids() {
  [[ -d "$SYNC_SNAPSHOT_DIR" ]] || return 0
  find "$SYNC_SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

prune_snapshots() {
  local keep="$SYNC_KEEP_SNAPSHOTS"
  [[ "$keep" =~ ^[0-9]+$ ]] || return 0
  local -a ids=()
  mapfile -t ids < <(snapshot_ids)
  local extra=$(( ${#ids[@]} - keep ))
  (( extra > 0 )) || return 0
  local i
  for ((i = 0; i < extra; i++)); do
    log "Pruning snapshot ${ids[i]}"
    rm -rf "${SYNC_SNAPSHOT_DIR:?}/${ids[i]}"
  done
}

from_ssh_host() {
  local var="SYNC_$(env_upper "$1")_SSH_HOST"
  printf '%s\n' "${!var:-${SYNC_SSH_HOST:-}}"
}
from_ssh_user() {
  local var="SYNC_$(env_upper "$1")_SSH_USER"
  printf '%s\n' "${!var:-${SYNC_SSH_USER:-}}"
}
from_ssh_port() {
  local var="SYNC_$(env_upper "$1")_SSH_PORT"
  printf '%s\n' "${!var:-${SYNC_SSH_PORT:-22}}"
}
from_ssh_identity() {
  local var="SYNC_$(env_upper "$1")_SSH_IDENTITY"
  printf '%s\n' "${!var:-${SYNC_SSH_IDENTITY:-}}"
}
from_ssh_path() {
  local var="SYNC_$(env_upper "$1")_PATH"
  printf '%s\n' "${!var:-${SYNC_SSH_PATH:-}}"
}
from_data_root() {
  local var
  var="SYNC_$(env_upper "$1")_DATA_ROOT"
  if [[ -n "${!var:-}" ]]; then
    printf '%s\n' "${!var}"
    return
  fi
  if [[ -n "${SYNC_REMOTE_DATA_ROOT:-}" ]]; then
    printf '%s\n' "$SYNC_REMOTE_DATA_ROOT"
    return
  fi
  if [[ -n "${SHOPWARE_SHOP_ID:-}" ]]; then
    printf '%s\n' "${SHOPWARE_DATA_BASE}/${SHOPWARE_SHOP_ID}/$1"
    return
  fi
  printf '%s\n' "$SHOPWARE_DATA_BASE"
}

ssh_rsh() {
  local a out=""
  ssh_base "$1"
  for a in "${SSH_CMD[@]}"; do
    out+="$(printf '%q ' "$a")"
  done
  printf '%s' "${out% }"
}

rsync_from_remote() {
  local from="$1" key="$2"
  local host user remote dest
  host="$(from_ssh_host "$from")"
  user="$(from_ssh_user "$from")"
  remote="$(from_data_root "$from")/$key"
  dest="$(host_data_dir "$key")"
  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    log "Rsync ${user}@${host}:${remote}/ → ${dest}/"
    rsync -a --delete -e "$(ssh_rsh "$from")" \
      "${user}@${host}:${remote}/" "${dest}/"
    return
  fi
  log "rsync not installed; streaming tar of $key from $from"
  remote_export "$from" "--data volumes --volume $(printf '%q' "$key")" \
    | restore_host_tar_stdin "$key"
}

ssh_base() {
  local from="$1" port ident known
  port="$(from_ssh_port "$from")"
  ident="$(from_ssh_identity "$from")"
  known="${SYNC_SSH_KNOWN_HOSTS:-}"
  SSH_CMD=(ssh -o BatchMode=yes -o IdentitiesOnly=yes)
  SSH_CMD+=(-o ControlMaster=auto -o "ControlPath=/tmp/shopware-sync-%C" -o ControlPersist=30)
  SSH_CMD+=(-p "$port")
  if [[ -n "$ident" ]]; then
    SSH_CMD+=(-i "$ident")
  fi
  if [[ -n "$known" ]]; then
    SSH_CMD+=(-o "UserKnownHostsFile=$known" -o StrictHostKeyChecking=yes)
  else
    SSH_CMD+=(-o StrictHostKeyChecking=accept-new)
  fi
}

remote_export() {
  local from="$1" args="$2" host user path
  host="$(from_ssh_host "$from")"
  user="$(from_ssh_user "$from")"
  path="$(from_ssh_path "$from")"
  [[ -n "$host" ]] || die "Set SYNC_SSH_HOST (or SYNC_$(env_upper "$from")_SSH_HOST) in deploy/sync.env"
  [[ -n "$user" ]] || die "Set SYNC_SSH_USER in deploy/sync.env"
  [[ -n "$path" ]] || die "Set SYNC_SSH_PATH in deploy/sync.env"
  ssh_base "$from"
  "${SSH_CMD[@]}" "${user}@${host}" \
    "set -euo pipefail; cd $(printf '%q' "$path"); bash ./deploy/sync-runtime.sh export $args"
}

cmd_export() {
  ensure_data_root
  case "$DATA" in
    db)
      dump_sql
      ;;
    volumes)
      [[ -n "$VOLUME_KEY" ]] || die "export --data volumes requires --volume <key>"
      dump_volume_tar "$VOLUME_KEY"
      ;;
    all)
      die "export --data all is not streamed as one payload; use db or volumes"
      ;;
  esac
}

cmd_snapshot() {
  acquire_lock
  ensure_data_root
  mkdir -p "$SYNC_SNAPSHOT_DIR"
  local id ts envn
  ts="$(date -u +%Y%m%dT%H%M%SZ)"
  envn="${SYNC_ENV:-local}"
  id="${SNAPSHOT_ID:-$ts-$envn}"
  local dir="$SYNC_SNAPSHOT_DIR/$id"
  mkdir -p "$dir"
  log "Snapshot $id → $dir"
  {
    printf 'id=%s\n' "$id"
    printf 'env=%s\n' "$envn"
    printf 'created_at=%s\n' "$ts"
    printf 'data=%s\n' "$DATA"
    printf 'volumes=%s\n' "$SYNC_VOLUMES"
    printf 'data_root=%s\n' "$SHOPWARE_DATA_ROOT"
  } >"$dir/meta.txt"
  if want_db; then
    log "Dumping database"
    dump_sql | gzip -c >"$dir/db.sql.gz"
  fi
  if want_volumes; then
    local key
    while IFS= read -r key; do
      snapshot_runtime_dir "$key" "$dir"
    done < <(volume_list)
  fi
  prune_snapshots
  log "Snapshot finished $id"
  printf '%s\n' "$id"
}

cmd_restore() {
  acquire_lock
  ensure_data_root
  if [[ -z "$SNAPSHOT_ID" ]]; then
    log "Available snapshots in $SYNC_SNAPSHOT_DIR:"
    snapshot_ids || true
    die "restore requires --snapshot <id>"
  fi
  local dir="$SYNC_SNAPSHOT_DIR/$SNAPSHOT_ID"
  [[ -d "$dir" ]] || die "Snapshot not found: $dir"
  local this_env="${SYNC_ENV:-}"
  if [[ -n "$this_env" ]] && is_live_env "$this_env"; then
    if [[ "${SYNC_ALLOW_LIVE_RESTORE:-0}" != 1 ]]; then
      die "Refusing restore onto live/prod (set SYNC_ALLOW_LIVE_RESTORE=1 for disaster recovery)"
    fi
  fi
  confirm "Overwrite runtime data on ${this_env:-this host} from snapshot $SNAPSHOT_ID?" \
    || die "Cancelled"
  stop_app
  if want_db; then
    [[ -f "$dir/db.sql.gz" ]] || die "Snapshot has no db.sql.gz"
    log "Importing database"
    gzip -dc "$dir/db.sql.gz" | import_sql
    rewrite_urls
  fi
  if want_volumes; then
    local key
    while IFS= read -r key; do
      restore_runtime_dir "$key" "$dir"
    done < <(volume_list)
    chown_volumes
  fi
  start_app
  cache_clear
  log "Restore finished $SNAPSHOT_ID"
}

cmd_sync() {
  acquire_lock
  ensure_data_root
  [[ -n "$FROM_ENV" ]] || die "sync requires --from <env> (e.g. --from live)"
  [[ -n "${SYNC_ENV:-}" ]] || die "Set SYNC_ENV in deploy/sync.env (this host, e.g. staging)"
  if is_live_env "$SYNC_ENV"; then
    die "Refusing sync onto live/prod (pull on the lower env, never push into live)"
  fi
  if [[ "$FROM_ENV" == "$SYNC_ENV" ]]; then
    die "--from ($FROM_ENV) is this host (SYNC_ENV=$SYNC_ENV)"
  fi
  local from_rank to_rank
  from_rank="$(env_rank "$FROM_ENV")"
  to_rank="$(env_rank "$SYNC_ENV")"
  if [[ "$to_rank" -le "$from_rank" ]]; then
    die "Refusing ${FROM_ENV} → ${SYNC_ENV} (only higher → lower, e.g. live → staging)"
  fi
  # Fail closed before stopping services.
  [[ -n "$(from_ssh_host "$FROM_ENV")" ]] || die "Set SYNC_SSH_HOST (or SYNC_$(env_upper "$FROM_ENV")_SSH_HOST) in deploy/sync.env"
  [[ -n "$(from_ssh_user "$FROM_ENV")" ]] || die "Set SYNC_SSH_USER in deploy/sync.env"
  [[ -n "$(from_ssh_path "$FROM_ENV")" ]] || die "Set SYNC_SSH_PATH in deploy/sync.env"
  confirm "Overwrite ${SYNC_ENV} runtime data with ${FROM_ENV} (${DATA})?" || die "Cancelled"
  stop_app
  if want_db; then
    log "Streaming mysqldump from $FROM_ENV"
    remote_export "$FROM_ENV" "--data db" | import_sql
    rewrite_urls
  fi
  if want_volumes; then
    local key
    while IFS= read -r key; do
      log "Syncing bind-mount dir $key from $FROM_ENV"
      rsync_from_remote "$FROM_ENV" "$key"
    done < <(volume_list)
    chown_volumes
  fi
  start_app
  cache_clear
  log "Sync finished ${FROM_ENV} → ${SYNC_ENV} ($DATA)"
}

case "$COMMAND" in
  export) cmd_export ;;
  snapshot) cmd_snapshot ;;
  restore) cmd_restore ;;
  sync) cmd_sync ;;
  *) die "Unknown command: $COMMAND" ;;
esac
