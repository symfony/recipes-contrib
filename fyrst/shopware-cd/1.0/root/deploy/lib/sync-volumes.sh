#!/usr/bin/env bash
# Bind-mount / named-volume rsync and tar archive helpers.
# Sourced by deploy/sync-runtime.sh. Safe to source from tests.

volume_docker_name() {
  local logical=$1
  printf '%s_%s\n' "$PROJECT_NAME" "$logical"
}

bind_item_dir() {
  local root=$1
  local logical=$2
  printf '%s/%s\n' "$root" "$logical"
}

resolve_remote_data_root() {
  if [[ "$SOURCE_IS_LOCAL" -eq 1 ]]; then
    REMOTE_DATA_ROOT="$DATA_ROOT"
    return
  fi
  if [[ -n "${REMOTE_DATA_ROOT}" ]]; then
    return
  fi
  SOURCE_ENV="$(source_env_for_remote)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    require_shop_id
    REMOTE_DATA_ROOT="$(derived_data_root "$SHOPWARE_SHOP_ID" "$SOURCE_ENV")"
    log "DRY-RUN remote SHOPWARE_DATA_ROOT derived ${REMOTE_DATA_ROOT} (probe skipped)"
    return
  fi
  local probed="" remote_printf
  # Expand SYNC_DATA_ROOT / SHOPWARE_DATA_ROOT on the remote after it sources .env.
  # Empty → derive from this host's SHOPWARE_SHOP_ID + SYNC_SOURCE_ENV/--from.
  # shellcheck disable=SC2016
  remote_printf='printf %s "${SYNC_DATA_ROOT:-${SHOPWARE_DATA_ROOT:-}}"'
  probed="$(remote_bash "$remote_printf" || true)"
  probed="$(printf '%s' "$probed" | tr -d '\r' | tail -n 1)"
  if [[ -n "$probed" ]]; then
    REMOTE_DATA_ROOT=$probed
    log "Remote bind-mount root: ${REMOTE_DATA_ROOT}"
    return
  fi
  require_shop_id
  REMOTE_DATA_ROOT="$(derived_data_root "$SHOPWARE_SHOP_ID" "$SOURCE_ENV")"
  log "Remote bind-mount root derived: ${REMOTE_DATA_ROOT} (shop=${SHOPWARE_SHOP_ID} env=${SOURCE_ENV})"
}

chown_data_dir() {
  local d=$1
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN chown 82:82 ${d}"
    return
  fi
  mkdir -p "$d"
  if chown -R 82:82 "$d" 2>/dev/null; then
    return
  fi
  docker run --rm -v "${d}:/to" "$ARCHIVE_IMAGE" chown -R 82:82 /to
}

rsync_local_trees() {
  local src=$1
  local dest=$2
  mkdir -p "$dest"
  rsync -aH --delete --numeric-ids "${src%/}/" "${dest%/}/"
}

rsync_from_remote_tree() {
  local remote_dir=$1
  local dest=$2
  mkdir -p "$dest"
  rsync -azH --delete --numeric-ids -e "${SSH_CMD[*]}" \
    "${SSH_TARGET}:${remote_dir%/}/" "${dest%/}/"
}

archive_volume_local() {
  local logical=$1
  local vol tarout
  vol="$(volume_docker_name "$logical")"
  tarout="${SNAPSHOT_DIR}/volumes/${logical}.tar.gz"
  log "Archiving named volume ${vol} → ${tarout} (bind-mount fallback)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN docker run --rm -v ${vol}:/from:ro -v ${SNAPSHOT_DIR}/volumes:/to ${ARCHIVE_IMAGE} tar"
    return
  fi
  if ! docker volume inspect "$vol" >/dev/null 2>&1; then
    die "Named volume '${vol}' not found and bind-mount $(bind_item_dir "$DATA_ROOT" "$logical") is missing. mkdir -p ${DATA_ROOT}/{files,media,thumbnail,theme,sitemap} && chown 82:82 (see deploy/README.md)."
  fi
  docker run --rm \
    -v "${vol}:/from:ro" \
    -v "${SNAPSHOT_DIR}/volumes:/to" \
    "$ARCHIVE_IMAGE" \
    tar -C /from -czf "/to/${logical}.tar.gz" .
  gzip -t "$tarout"
}

archive_volume_remote() {
  local logical=$1
  local vol tarout
  vol="$(volume_docker_name "$logical")"
  tarout="${SNAPSHOT_DIR}/volumes/${logical}.tar.gz"
  log "Archiving remote named volume ${vol} on ${SSH_TARGET} → ${tarout} (bind-mount fallback)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN ssh ${SSH_TARGET} docker run -v ${vol}:/from:ro ${ARCHIVE_IMAGE} tar -czf -"
    return
  fi
  remote_bash "if ! docker volume inspect $(printf '%q' "$vol") >/dev/null 2>&1; then
  echo \"Named volume ${vol} not found on source (project ${PROJECT_NAME}).\" >&2
  exit 1
fi
docker run --rm -v $(printf '%q' "${vol}"):/from:ro $(printf '%q' "$ARCHIVE_IMAGE") tar -C /from -czf - ." >"$tarout"
  if [[ ! -s "$tarout" ]]; then
    die "Remote volume archive for ${logical} was empty"
  fi
  gzip -t "$tarout"
}

restore_volume_local() {
  local logical=$1
  local vol tarin
  vol="$(volume_docker_name "$logical")"
  tarin="${SNAPSHOT_DIR}/volumes/${logical}.tar.gz"
  if [[ ! -f "$tarin" ]]; then
    die "Missing ${tarin}"
  fi
  log "Restoring named volume ${vol} from ${tarin} (bind-mount fallback)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN docker volume create ${vol}; extract tar into ${vol}; chown 82:82"
    return
  fi
  gzip -t "$tarin"
  docker volume create "$vol" >/dev/null
  docker run --rm \
    -v "${vol}:/to" \
    -v "${SNAPSHOT_DIR}/volumes:/from:ro" \
    "$ARCHIVE_IMAGE" \
    sh -c "set -eu
      find /to -mindepth 1 -maxdepth 1 -exec rm -rf {} +
      tar -C /to -xzf /from/${logical}.tar.gz
      chown -R 82:82 /to || true"
}

snapshot_bind_local() {
  local logical=$1
  local src dest
  src="$(bind_item_dir "$DATA_ROOT" "$logical")"
  dest="${SNAPSHOT_DIR}/data/${logical}"
  if [[ -d "$src" ]]; then
    log "Snapshot bind mount ${src} → ${dest}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN rsync ${src}/ ${dest}/"
      return
    fi
    if command -v rsync >/dev/null 2>&1; then
      rsync_local_trees "$src" "$dest"
    else
      mkdir -p "$dest"
      tar -C "$src" -czf "${SNAPSHOT_DIR}/volumes/${logical}.tar.gz" .
    fi
    return
  fi
  log "Bind mount ${src} missing; trying named volume"
  archive_volume_local "$logical"
}

snapshot_bind_remote() {
  local logical=$1
  local src dest
  src="$(bind_item_dir "$REMOTE_DATA_ROOT" "$logical")"
  dest="${SNAPSHOT_DIR}/data/${logical}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN rsync ${SSH_TARGET}:${src}/ → ${dest}/"
    return
  fi
  if remote_dir_exists "$src"; then
    log "Snapshot remote bind mount ${SSH_TARGET}:${src} → ${dest}"
    if command -v rsync >/dev/null 2>&1; then
      rsync_from_remote_tree "$src" "$dest"
    else
      mkdir -p "$(dirname "${SNAPSHOT_DIR}/volumes/${logical}.tar.gz")"
      remote_bash "docker run --rm -v $(printf '%q' "$src"):/from:ro $(printf '%q' "$ARCHIVE_IMAGE") tar -C /from -czf - ." >"${SNAPSHOT_DIR}/volumes/${logical}.tar.gz"
      gzip -t "${SNAPSHOT_DIR}/volumes/${logical}.tar.gz"
    fi
    return
  fi
  log "Remote bind mount ${src} missing; trying named volume"
  archive_volume_remote "$logical"
}

restore_bind_local() {
  local logical=$1
  local dest snapdir tarin
  dest="$(bind_item_dir "$DATA_ROOT" "$logical")"
  snapdir="${SNAPSHOT_DIR}/data/${logical}"
  tarin="${SNAPSHOT_DIR}/volumes/${logical}.tar.gz"
  if [[ -d "$snapdir" ]]; then
    log "Restoring bind mount ${dest} from ${snapdir}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN rsync ${snapdir}/ ${dest}/; chown 82:82"
      return
    fi
    mkdir -p "$dest" 2>/dev/null || true
    if command -v rsync >/dev/null 2>&1 && [[ -d "$dest" && -w "$dest" ]] && rsync_local_trees "$snapdir" "$dest"; then
      chown_data_dir "$dest"
    else
      docker run --rm -v "${dest}:/to" -v "${snapdir}:/from:ro" "$ARCHIVE_IMAGE" \
        sh -c 'set -eu; find /to -mindepth 1 -maxdepth 1 -exec rm -rf {} +; cp -a /from/. /to/; chown -R 82:82 /to || true'
    fi
    return
  fi
  if [[ -f "$tarin" ]]; then
    log "Restoring ${dest} from tar ${tarin}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN extract ${tarin} into ${dest}"
      return
    fi
    mkdir -p "$dest"
    gzip -t "$tarin"
    docker run --rm \
      -v "${dest}:/to" \
      -v "${SNAPSHOT_DIR}/volumes:/from:ro" \
      "$ARCHIVE_IMAGE" \
      sh -c "set -eu
        find /to -mindepth 1 -maxdepth 1 -exec rm -rf {} +
        tar -C /to -xzf /from/${logical}.tar.gz
        chown -R 82:82 /to || true"
    return
  fi
  restore_volume_local "$logical"
}


# Cron path: rsync remote SHOPWARE_DATA_ROOT/<item> → local (no snapshot tree).
sync_bind_from_remote() {
  local logical=$1
  local src dest
  src="$(bind_item_dir "$REMOTE_DATA_ROOT" "$logical")"
  dest="$(bind_item_dir "$DATA_ROOT" "$logical")"
  log "Rsync ${SSH_TARGET}:${src}/ → ${dest}/"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN rsync -az --delete ${SSH_TARGET}:${src}/ ${dest}/; chown 82:82"
    return
  fi
  mkdir -p "$dest" 2>/dev/null || true
  if remote_dir_exists "$src" && command -v rsync >/dev/null 2>&1 && [[ -d "$dest" && -w "$dest" ]]; then
    if rsync_from_remote_tree "$src" "$dest"; then
      chown_data_dir "$dest"
      return
    fi
    log "rsync into ${dest} failed (permissions?); tar via SSH + docker extract"
  fi
  if remote_dir_exists "$src"; then
    remote_bash "docker run --rm -v $(printf '%q' "$src"):/from:ro $(printf '%q' "$ARCHIVE_IMAGE") tar -C /from -czf - ." \
      | docker run --rm -i -v "${dest}:/to" "$ARCHIVE_IMAGE" \
        sh -c 'set -eu; find /to -mindepth 1 -maxdepth 1 -exec rm -rf {} +; tar -C /to -xzf -; chown -R 82:82 /to || true'
    return
  fi
  log "Remote bind mount ${src} missing; named-volume fallback into snapshot then restore"
  archive_volume_remote "$logical"
  restore_bind_local "$logical"
}
