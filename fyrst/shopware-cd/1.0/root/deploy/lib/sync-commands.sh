#!/usr/bin/env bash
# CLI bootstrap + snapshot/restore/sync orchestration.
# Sourced by deploy/sync-runtime.sh. Safe to source from tests (no side effects).

DEFAULT_DATA="${DEFAULT_DATA:-db,media,files,thumbnail,theme,sitemap}"

normalize_data() {
  local spec=$1
  local item lower
  local -a raw=()
  WANT_DB=0
  WANT_VOLUMES=()
  DATA_ITEMS=()

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

  for item in "${raw[@]}"; do
    lower=$(printf '%s' "$item" | tr '[:upper:]' '[:lower:]')
    case "$lower" in
      db | database | mysql)
        WANT_DB=1
        DATA_ITEMS+=("db")
        ;;
      files | media | thumbnail | theme | sitemap)
        WANT_VOLUMES+=("$lower")
        DATA_ITEMS+=("$lower")
        ;;
      mysql_data | redis_data)
        die "Refusing volume '${lower}'. Copy the database with --data db (SQL dump), not the ${lower} volume."
        ;;
      *)
        die "Unknown --data item '${item}'. Use db, files, media, thumbnail, theme, sitemap, or all."
        ;;
    esac
  done

  if [[ "$SKIP_DB" -eq 1 ]]; then
    WANT_DB=0
  fi
  if [[ "$SKIP_VOLUMES" -eq 1 ]]; then
    WANT_VOLUMES=()
  fi

  DATA_ITEMS=()
  if [[ "$WANT_DB" -eq 1 ]]; then
    DATA_ITEMS+=("db")
  fi
  local vol
  for vol in "${WANT_VOLUMES[@]+"${WANT_VOLUMES[@]}"}"; do
    DATA_ITEMS+=("$vol")
  done

  if [[ "$WANT_DB" -eq 0 && ${#WANT_VOLUMES[@]} -eq 0 ]]; then
    die "Nothing to do (--data plus --skip-db/--skip-volumes selected an empty set)"
  fi
}

assert_tools() {
  require_cmd bash
  require_cmd gzip
  require_cmd docker
  if ! docker compose version >/dev/null 2>&1; then
    die "docker compose plugin not found. Install Docker Engine + Compose v2."
  fi
  if ! docker info >/dev/null 2>&1; then
    die "Cannot talk to the Docker daemon. Add this user to the docker group or run where the daemon is reachable."
  fi
  if [[ "$SOURCE_IS_LOCAL" -eq 0 ]]; then
    require_cmd ssh
    if [[ -n "${SYNC_SSH_KEY:-}" && ! -f "${SYNC_SSH_KEY}" ]]; then
      die "SYNC_SSH_KEY not found: ${SYNC_SSH_KEY}"
    fi
  fi
  if [[ ${#WANT_VOLUMES[@]} -gt 0 ]] && ! command -v rsync >/dev/null 2>&1; then
    log "rsync not installed; bind-mount trees will use tar (install rsync for incremental live→staging copies)"
  fi
}

ensure_snapshot_dir() {
  if [[ "$SNAPSHOT_DIR" != /* ]]; then
    SNAPSHOT_DIR="${COMPOSE_DIR}/${SNAPSHOT_DIR}"
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Snapshot directory: ${SNAPSHOT_DIR}"
    return
  fi
    mkdir -p "${SNAPSHOT_DIR}/volumes" "${SNAPSHOT_DIR}/data"
    chmod 700 "$SNAPSHOT_DIR"
}

lock_sync() {
  local lock="${SNAPSHOT_DIR}.lock"
  mkdir -p "$(dirname "$lock")"
  exec 9>"$lock"
  if command -v flock >/dev/null 2>&1; then
    if ! flock -n 9; then
      die "Another sync-runtime.sh run holds ${lock}. Cron overlap — wait or remove a stale lock."
    fi
  fi
}

write_manifest() {
  local dest="${SNAPSHOT_DIR}/MANIFEST.txt"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Would write ${dest}"
    return
  fi
  {
    printf 'shopware-runtime-snapshot 1\n'
    printf 'created=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'source_alias=%s\n' "$FROM"
    printf 'source_local=%s\n' "$SOURCE_IS_LOCAL"
    printf 'source_host=%s\n' "${SYNC_SSH_HOST:-localhost}"
    printf 'consumer_sync_env=%s\n' "${SYNC_ENV:-}"
    printf 'consumer_host=%s\n' "$(hostname -f 2>/dev/null || hostname)"
    printf 'compose_dir=%s\n' "$COMPOSE_DIR"
    printf 'project=%s\n' "$PROJECT_NAME"
    printf 'data=%s\n' "$(IFS=','; echo "${DATA_ITEMS[*]}")"
    printf 'data_root=%s\n' "$DATA_ROOT"
    printf 'remote_data_root=%s\n' "${REMOTE_DATA_ROOT:-}"
    printf 'transport=ssh+shopware-cli-project-dump+rsync-bind-mounts\n'
    printf 'dump_engine=%s\n' "$(sync_dump_engine)"
    printf 'dump_image=%s\n' "$(sync_dump_image)"
    printf 'object_storage=out-of-scope\n'
  } >"$dest"
  if command -v sha256sum >/dev/null 2>&1; then
    (
      cd "$SNAPSHOT_DIR" || exit
      sha256sum db.sql.gz db.sql volumes/*.tar.gz 2>/dev/null || true
    ) >>"$dest"
  fi
}

remote_has_sync_script() {
  remote_bash "test -f deploy/sync-runtime.sh"
}

pull_snapshot_tree() {
  local remote_dir="${SYNC_REMOTE_SNAPSHOT_DIR:-${REMOTE_PATH}/var/runtime-sync}"
  log "Fetching snapshot directory from ${SSH_TARGET}:${remote_dir}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN rsync or tar-over-ssh ${SSH_TARGET}:${remote_dir}/ → ${SNAPSHOT_DIR}/"
    return
  fi
  mkdir -p "$SNAPSHOT_DIR"
  if command -v rsync >/dev/null 2>&1; then
    rsync -az --delete -e "${SSH_CMD[*]}" "${SSH_TARGET}:${remote_dir}/" "${SNAPSHOT_DIR}/"
  else
    log "rsync not installed; using tar over ssh"
    require_cmd tar
    remote_bash "tar -C $(printf '%q' "$remote_dir") -czf - ." | tar -C "$SNAPSHOT_DIR" -xzf -
  fi
}

snapshot_remote_via_script() {
  local remote_dir="${SYNC_REMOTE_SNAPSHOT_DIR:-${REMOTE_PATH}/var/runtime-sync}"
  local data_csv=$1
  log "Running snapshot on ${SSH_TARGET} via deploy/sync-runtime.sh"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN ssh ${SSH_TARGET} bash deploy/sync-runtime.sh snapshot --from local --data ${data_csv} --snapshot-dir ${remote_dir}"
    return
  fi
  remote_bash "bash deploy/sync-runtime.sh snapshot --from local --data $(printf '%q' "$data_csv") --snapshot-dir $(printf '%q' "$remote_dir")"
  pull_snapshot_tree
}

data_csv_effective() {
  local parts=()
  if [[ "$WANT_DB" -eq 1 ]]; then
    parts+=(db)
  fi
  local v
  for v in "${WANT_VOLUMES[@]+"${WANT_VOLUMES[@]}"}"; do
    parts+=("$v")
  done
  local IFS=,
  printf '%s' "${parts[*]}"
}

do_snapshot() {
  ensure_snapshot_dir
  if [[ "$SOURCE_IS_LOCAL" -eq 1 ]]; then
    resolve_project_name
    if [[ "$WANT_DB" -eq 1 ]]; then
      dump_db_local
    fi
    local vol
    for vol in "${WANT_VOLUMES[@]+"${WANT_VOLUMES[@]}"}"; do
      snapshot_bind_local "$vol"
    done
    write_manifest
    log "Snapshot written to ${SNAPSHOT_DIR}"
    return
  fi

  probe_ssh
  resolve_remote_data_root
  local csv
  csv="$(data_csv_effective)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Would snapshot from ${SSH_TARGET} (--data ${csv}) bind-mounts under ${REMOTE_DATA_ROOT}"
    resolve_project_name
    if [[ "$WANT_DB" -eq 1 ]]; then
      dump_db_remote
    fi
    local vol
    for vol in "${WANT_VOLUMES[@]+"${WANT_VOLUMES[@]}"}"; do
      snapshot_bind_remote "$vol"
    done
    write_manifest
    return
  fi

  if remote_has_sync_script; then
    snapshot_remote_via_script "$csv"
    log "Snapshot pulled to ${SNAPSHOT_DIR}"
    return
  fi

  log "Remote deploy/sync-runtime.sh not found; streaming dump/rsync over SSH"
  resolve_remote_project_name
  if [[ "$WANT_DB" -eq 1 ]]; then
    dump_db_remote
  fi
  local vol
  for vol in "${WANT_VOLUMES[@]+"${WANT_VOLUMES[@]}"}"; do
    snapshot_bind_remote "$vol"
  done
  write_manifest
  log "Snapshot written to ${SNAPSHOT_DIR}"
}

do_restore() {
  assert_not_live_restore
  ensure_snapshot_dir
  resolve_project_name
  if [[ "$DRY_RUN" -eq 0 && ! -d "$SNAPSHOT_DIR" ]]; then
    die "Snapshot directory not found: ${SNAPSHOT_DIR}"
  fi
  stop_app_containers
  if [[ "$WANT_DB" -eq 1 ]]; then
    restore_db_local
    maybe_rewrite_sales_channel_domains
  else
    maybe_rewrite_sales_channel_domains
  fi
  local vol
  for vol in "${WANT_VOLUMES[@]+"${WANT_VOLUMES[@]}"}"; do
    restore_bind_local "$vol"
  done
  start_stopped_app
  post_restore_hints
  log "Restore finished into ${COMPOSE_DIR} data_root=${DATA_ROOT} (SYNC_ENV=${SYNC_ENV:-unset})"
}

do_sync() {
  if [[ "$SOURCE_IS_LOCAL" -eq 1 ]]; then
    log "sync --from local snapshots this host then restores the same files (pipeline check). Prefer --from <live-alias> on staging."
    do_snapshot
    do_restore
    return
  fi
  probe_ssh
  resolve_remote_data_root
  resolve_project_name
  stop_app_containers
  if [[ "$WANT_DB" -eq 1 ]]; then
    dump_db_remote
    restore_db_local
  fi
  maybe_rewrite_sales_channel_domains
  local vol
  for vol in "${WANT_VOLUMES[@]+"${WANT_VOLUMES[@]}"}"; do
    sync_bind_from_remote "$vol"
  done
  start_stopped_app
  post_restore_hints
  log "Sync finished from ${FROM} → ${DATA_ROOT} (SYNC_ENV=${SYNC_ENV:-unset})"
}

sync_cli_defaults() {
  COMPOSE_DIR="${COMPOSE_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
  COMMAND="${COMMAND:-}"
  FROM="${FROM:-local}"
  DATA_SPEC="${DATA_SPEC:-all}"
  SNAPSHOT_DIR="${SNAPSHOT_DIR:-}"
  DRY_RUN="${DRY_RUN:-0}"
  SKIP_DB="${SKIP_DB:-0}"
  SKIP_VOLUMES="${SKIP_VOLUMES:-0}"
  SOURCE_IS_LOCAL="${SOURCE_IS_LOCAL:-1}"
  SSH_TARGET="${SSH_TARGET:-}"
  REMOTE_PATH="${REMOTE_PATH:-}"
  PROJECT_NAME="${PROJECT_NAME:-}"
  ARCHIVE_IMAGE="${SYNC_ARCHIVE_IMAGE:-alpine:3.20}"
  DATA_ROOT="${DATA_ROOT:-}"
  REMOTE_DATA_ROOT="${REMOTE_DATA_ROOT:-}"
  SOURCE_ENV="${SOURCE_ENV:-}"
  STOPPED_APP=("${STOPPED_APP[@]+"${STOPPED_APP[@]}"}")
  WANT_DB="${WANT_DB:-0}"
  WANT_VOLUMES=("${WANT_VOLUMES[@]+"${WANT_VOLUMES[@]}"}")
  DATA_ITEMS=("${DATA_ITEMS[@]+"${DATA_ITEMS[@]}"}")
  SSH_CMD=("${SSH_CMD[@]+"${SSH_CMD[@]}"}")
}

sync_load_shop_and_sync_env() {
  PRESET_SYNC_ENV="${SYNC_ENV:-}"
  PRESET_IMAGE="${IMAGE:-}"
  PRESET_IMAGE_TAG="${IMAGE_TAG:-}"
  PRESET_SYNC_DATA_ROOT="${SYNC_DATA_ROOT:-}"
  PRESET_SHOPWARE_SHOP_ID="${SHOPWARE_SHOP_ID:-}"
  PRESET_SHOPWARE_DEPLOY_ENV="${SHOPWARE_DEPLOY_ENV:-}"
  PRESET_COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-}"
  PRESET_SHOPWARE_DATA_ROOT="${SHOPWARE_DATA_ROOT:-}"
  PRESET_SHOPWARE_DATA_BASE="${SHOPWARE_DATA_BASE:-}"
  PRESET_SYNC_SOURCE_ENV="${SYNC_SOURCE_ENV:-}"
  PRESET_SYNC_REMOTE_DATA_ROOT="${SYNC_REMOTE_DATA_ROOT:-}"

  load_env_file .env
  load_env_file .env.prod
  load_env_file deploy/sync.env

  SYNC_ENV="${PRESET_SYNC_ENV:-${SYNC_ENV:-}}"
  IMAGE="${PRESET_IMAGE:-${IMAGE:-}}"
  IMAGE_TAG="${PRESET_IMAGE_TAG:-${IMAGE_TAG:-latest}}"
  SHOPWARE_SHOP_ID="${PRESET_SHOPWARE_SHOP_ID:-${SHOPWARE_SHOP_ID:-}}"
  SHOPWARE_DEPLOY_ENV="${PRESET_SHOPWARE_DEPLOY_ENV:-${SHOPWARE_DEPLOY_ENV:-}}"
  COMPOSE_PROJECT_NAME="${PRESET_COMPOSE_PROJECT_NAME:-${COMPOSE_PROJECT_NAME:-}}"
  SHOPWARE_DATA_ROOT="${PRESET_SHOPWARE_DATA_ROOT:-${SHOPWARE_DATA_ROOT:-}}"
  SHOPWARE_DATA_BASE="${PRESET_SHOPWARE_DATA_BASE:-${SHOPWARE_DATA_BASE:-$DEFAULT_DATA_BASE}}"
  SYNC_SOURCE_ENV="${PRESET_SYNC_SOURCE_ENV:-${SYNC_SOURCE_ENV:-}}"
  SYNC_REMOTE_DATA_ROOT="${PRESET_SYNC_REMOTE_DATA_ROOT:-${SYNC_REMOTE_DATA_ROOT:-}}"
  export IMAGE IMAGE_TAG
}

sync_bootstrap() {
  cd "$COMPOSE_DIR" || die "Cannot cd to COMPOSE_DIR=${COMPOSE_DIR}"
  sync_load_shop_and_sync_env
  SNAPSHOT_DIR="${SNAPSHOT_DIR:-${SYNC_SNAPSHOT_DIR:-${COMPOSE_DIR}/var/runtime-sync}}"
  require_shop_id
  derive_local_data_root
  normalize_data "$DATA_SPEC"
  sync_refresh_live_consumer
  FROM_LC="$(lower_s "$FROM")"
  resolve_source
  sync_init_ssh_cmd
  compose_init
  derive_compose_project_name
  if [[ "$COMMAND" == "restore" || "$COMMAND" == "sync" ]]; then
    assert_not_live_restore
    assert_not_live_rewrite
  fi
  assert_tools
  ensure_image_for_compose
  ensure_snapshot_dir
  lock_sync

  log "Runtime data ${COMMAND}  from=${FROM}  data=$(data_csv_effective)  shop=${SHOPWARE_SHOP_ID}  deploy_env=${SHOPWARE_DEPLOY_ENV:-unset}  project=${COMPOSE_PROJECT_NAME:-}  env=${SYNC_ENV:-unset}  data_root=${DATA_ROOT}  dry-run=${DRY_RUN}"
  if [[ "$SOURCE_IS_LOCAL" -eq 0 ]]; then
    log "SSH ${SSH_TARGET} port ${SYNC_SSH_PORT:-22}  remote=${REMOTE_PATH}"
  fi
}
