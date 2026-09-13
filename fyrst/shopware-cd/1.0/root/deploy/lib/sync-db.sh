#!/usr/bin/env bash
# Database dump (shopware-cli / mysqldump escape hatch) and MySQL client restore.
# Sourced by deploy/sync-runtime.sh. Integrates lib/sync-dump.sh (flags only).
# Safe to source from tests (no side effects).


# POSIX sh: runs inside the mysql/mariadb container (official images use dash).
# Used only when SYNC_DUMP_ENGINE=mysqldump.
mysql_dump_sh() {
  cat <<'EOS'
set -eu
DB="${MYSQL_DATABASE:-shopware}"
if command -v mariadb-dump >/dev/null 2>&1; then
  D=mariadb-dump
elif command -v mysqldump >/dev/null 2>&1; then
  D=mysqldump
else
  echo "Neither mysqldump nor mariadb-dump is in the mysql container" >&2
  exit 1
fi
if command -v mariadb >/dev/null 2>&1; then
  CLI=mariadb
elif command -v mysql >/dev/null 2>&1; then
  CLI=mysql
else
  CLI=""
fi
FLAGS="--single-transaction --quick --routines --triggers --events --hex-blob --no-tablespaces --default-character-set=utf8mb4"
if [ "$D" = mysqldump ]; then
  FLAGS="$FLAGS --column-statistics=0"
fi
# shellcheck disable=SC2086
if [ -n "$CLI" ] && "$CLI" -uroot --protocol=socket -e "SELECT 1" >/dev/null 2>&1; then
  "$D" -uroot --protocol=socket $FLAGS "$DB"
elif [ -n "$CLI" ] && [ -n "${MYSQL_ROOT_PASSWORD:-}" ] && "$CLI" -uroot -p"${MYSQL_ROOT_PASSWORD}" -h127.0.0.1 -e "SELECT 1" >/dev/null 2>&1; then
  "$D" -uroot -p"${MYSQL_ROOT_PASSWORD}" -h127.0.0.1 $FLAGS "$DB"
elif [ -n "$CLI" ] && [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ] && "$CLI" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h127.0.0.1 -e "SELECT 1" >/dev/null 2>&1; then
  "$D" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h127.0.0.1 $FLAGS "$DB"
else
  "$D" -uroot --protocol=socket $FLAGS "$DB"
fi
EOS
}

mysql_restore_sh() {
  cat <<'EOS'
set -eu
DB="${MYSQL_DATABASE:-shopware}"
if command -v mariadb >/dev/null 2>&1; then
  CLI=mariadb
elif command -v mysql >/dev/null 2>&1; then
  CLI=mysql
else
  echo "Neither mysql nor mariadb client is in the mysql container" >&2
  exit 1
fi
if "$CLI" -uroot --protocol=socket -e "SELECT 1" >/dev/null 2>&1; then
  "$CLI" -uroot --protocol=socket --max-allowed-packet=1G "$DB"
elif [ -n "${MYSQL_ROOT_PASSWORD:-}" ] && "$CLI" -uroot -p"${MYSQL_ROOT_PASSWORD}" -h127.0.0.1 -e "SELECT 1" >/dev/null 2>&1; then
  "$CLI" -uroot -p"${MYSQL_ROOT_PASSWORD}" -h127.0.0.1 --max-allowed-packet=1G "$DB"
elif [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ] && "$CLI" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h127.0.0.1 -e "SELECT 1" >/dev/null 2>&1; then
  "$CLI" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h127.0.0.1 --max-allowed-packet=1G "$DB"
else
  "$CLI" -uroot --protocol=socket --max-allowed-packet=1G "$DB"
fi
EOS
}

mysql_wait_sh() {
  cat <<'EOS'
set -eu
i=0
while [ "$i" -lt 40 ]; do
  i=$((i + 1))
  if command -v mysqladmin >/dev/null 2>&1 && mysqladmin ping -h 127.0.0.1 --silent; then
    exit 0
  fi
  if command -v mariadb-admin >/dev/null 2>&1 && mariadb-admin ping -h 127.0.0.1 --silent; then
    exit 0
  fi
  sleep 2
done
echo "mysql did not become ready" >&2
exit 1
EOS
}

urldecode() {
  local s=$1
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import sys,urllib.parse; print(urllib.parse.unquote(sys.argv[1]), end="")' "$s"
    return
  fi
  printf '%b' "${s//%/\\x}"
}

parse_database_url() {
  local url="${DATABASE_URL:-}"
  DB_SCHEME=""
  DB_USER=""
  DB_PASS=""
  DB_HOST=""
  DB_PORT="3306"
  DB_NAME=""
  if [[ -z "$url" ]]; then
    return 1
  fi
  DB_SCHEME="${url%%://*}"
  local rest="${url#*://}"
  rest="${rest%%\?*}"
  local creds hostpart
  if [[ "$rest" == *@* ]]; then
    creds="${rest%%@*}"
    hostpart="${rest#*@}"
  else
    creds=""
    hostpart=$rest
  fi
  if [[ -n "$creds" ]]; then
    DB_USER="${creds%%:*}"
    if [[ "$creds" == *:* ]]; then
      DB_PASS="${creds#*:}"
    fi
    DB_USER="$(urldecode "$DB_USER")"
    DB_PASS="$(urldecode "$DB_PASS")"
  fi
  local hp="${hostpart%%/*}"
  if [[ "$hostpart" == */* ]]; then
    DB_NAME="${hostpart#*/}"
  fi
  DB_NAME="${DB_NAME%%/*}"
  if [[ "$hp" == \[* ]]; then
    DB_HOST="${hp#\[}"
    DB_HOST="${DB_HOST%%]*}"
    local after="${hp#*]}"
    if [[ "$after" == :* ]]; then
      DB_PORT="${after#:}"
    fi
  elif [[ "$hp" == *:* ]]; then
    DB_HOST="${hp%%:*}"
    DB_PORT="${hp#*:}"
  else
    DB_HOST=$hp
  fi
  if [[ -z "$DB_NAME" ]]; then
    DB_NAME="${MYSQL_DATABASE:-shopware}"
  fi
}

mysql_up_local() {
  if ! has_mysql_service_local; then
    return 1
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Would start compose service mysql if needed"
    return 0
  fi
  "${COMPOSE[@]}" up -d --no-build mysql
  "${COMPOSE[@]}" exec -T mysql sh -c "$(mysql_wait_sh)"
}

client_image_for_url() {
  case "${DB_SCHEME:-mysql}" in
    mariadb) printf '%s\n' "${SYNC_MYSQL_CLIENT_IMAGE:-mariadb:11.4}" ;;
    *) printf '%s\n' "${SYNC_MYSQL_CLIENT_IMAGE:-mysql:8.4}" ;;
  esac
}

assert_dump_engine() {
  if sync_dump_engine_is_shopware_cli || sync_dump_engine_is_mysqldump; then
    return
  fi
  die "Unknown SYNC_DUMP_ENGINE=${SYNC_DUMP_ENGINE:-}. Use shopware-cli (default) or mysqldump."
}


# Compose default network for the bundled mysql service (hostname: mysql).
compose_project_network() {
  local cid net
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '%s_default\n' "${PROJECT_NAME:-shopware}"
    return 0
  fi
  cid="$("${COMPOSE[@]}" ps -q mysql 2>/dev/null | tr -d '\r' | tail -n 1 || true)"
  if [[ -n "$cid" ]]; then
    net="$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{println $k}}{{end}}' "$cid" 2>/dev/null | awk 'NF { print; exit }')"
    net="$(printf '%s' "$net" | tr -d '\r')"
    if [[ -n "$net" ]]; then
      printf '%s\n' "$net"
      return 0
    fi
  fi
  if [[ -n "${PROJECT_NAME:-}" ]]; then
    printf '%s_default\n' "$PROJECT_NAME"
    return 0
  fi
  return 1
}

ensure_shopware_cli_image() {
  local img
  img="$(sync_dump_image)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Would use shopware-cli image ${img}"
    return 0
  fi
  if docker image inspect "$img" >/dev/null 2>&1; then
    return 0
  fi
  log "Pulling ${img} (shopware-cli project dump; not present locally)"
  if ! docker pull "$img"; then
    die "$(sync_dump_fail_hint)"
  fi
}


# Sets DUMP_HOST DUMP_PORT DUMP_USER DUMP_PASS DUMP_DB DUMP_NETWORK (no secrets logged).
resolve_dump_connection_local() {
  DUMP_HOST=""
  DUMP_PORT="3306"
  DUMP_USER=""
  DUMP_PASS=""
  DUMP_DB="${MYSQL_DATABASE:-shopware}"
  DUMP_NETWORK=""

  if has_mysql_service_local; then
    mysql_up_local
    DUMP_NETWORK="$(compose_project_network)" || die "Cannot determine Compose network for mysql (project ${PROJECT_NAME:-unset})."
    DUMP_HOST="mysql"
    if [[ -n "${MYSQL_USER:-}" ]]; then
      DUMP_USER=$MYSQL_USER
      DUMP_PASS="${MYSQL_PASSWORD:-}"
      DUMP_DB="${MYSQL_DATABASE:-$DUMP_DB}"
    elif parse_database_url && [[ -n "${DB_USER:-}" ]]; then
      DUMP_USER=$DB_USER
      DUMP_PASS=$DB_PASS
      DUMP_DB="${DB_NAME:-$DUMP_DB}"
      [[ -n "${DB_PORT:-}" ]] && DUMP_PORT=$DB_PORT
    elif [[ -n "${MYSQL_ROOT_PASSWORD:-}" ]]; then
      DUMP_USER=root
      DUMP_PASS=$MYSQL_ROOT_PASSWORD
    else
      die "Cannot dump bundled mysql: set MYSQL_USER/MYSQL_PASSWORD (or MYSQL_ROOT_PASSWORD) or DATABASE_URL in .env."
    fi
    return
  fi

  parse_database_url || die "No bundled mysql service and DATABASE_URL is missing. Set DATABASE_URL or keep the mysql service in deploy/compose.yaml."
  if [[ "$DB_HOST" == "mysql" ]]; then
    die "DATABASE_URL host is 'mysql' but the compose mysql service is not available on the source. Start the stack or point DATABASE_URL at the real database host."
  fi
  DUMP_NETWORK="host"
  DUMP_HOST=$DB_HOST
  DUMP_PORT="${DB_PORT:-3306}"
  DUMP_USER=$DB_USER
  DUMP_PASS=$DB_PASS
  DUMP_DB=$DB_NAME
}

append_dump_connection_flags() {
  local -n _sync_dump_conn=$1
  [[ -n "${DUMP_HOST:-}" ]] && _sync_dump_conn+=(--host "$DUMP_HOST")
  [[ -n "${DUMP_PORT:-}" ]] && _sync_dump_conn+=(--port "$DUMP_PORT")
  [[ -n "${DUMP_USER:-}" ]] && _sync_dump_conn+=(--username "$DUMP_USER")
  if [[ -n "${DUMP_PASS:-}" ]]; then
    _sync_dump_conn+=("--password=${DUMP_PASS}")
  fi
  [[ -n "${DUMP_DB:-}" ]] && _sync_dump_conn+=(--database "$DUMP_DB")
}

finish_dump_file() {
  local output=$1
  if [[ ! -s "$output" ]]; then
    die "shopware-cli project dump produced an empty ${output}"
  fi
  gzip -t "$output" || die "Dump at ${output} is not valid gzip (expected shopware-cli --compression=gzip --output)."
  chown "$(id -u):$(id -g)" "$output" 2>/dev/null || true
  chmod 600 "$output" 2>/dev/null || true
}

run_shopware_cli_dump_local() {
  local output="${SNAPSHOT_DIR}/db.sql.gz"
  local img
  img="$(sync_dump_image)"
  resolve_dump_connection_local
  ensure_shopware_cli_image
  local -a run=(
    docker run --rm
    --network "$DUMP_NETWORK"
    -v "${COMPOSE_DIR}:${COMPOSE_DIR}:ro"
    -v "${SNAPSHOT_DIR}:${SNAPSHOT_DIR}"
    -w "${COMPOSE_DIR}"
    -e HOME=/tmp
    -e SHOPWARE_CLI_NO_UPDATE_NOTIFICATION=true
    "$img"
  )
  local -a flags=()
  sync_dump_append_project_flags flags "$output"
  append_dump_connection_flags flags
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN docker run --rm --network ${DUMP_NETWORK} -v ${COMPOSE_DIR}:${COMPOSE_DIR}:ro -v ${SNAPSHOT_DIR}:${SNAPSHOT_DIR} -w ${COMPOSE_DIR} ${img} $(sync_dump_flags_log "$output") --host ${DUMP_HOST} --port ${DUMP_PORT} --username ${DUMP_USER} --database ${DUMP_DB}"
    return
  fi
  if ! "${run[@]}" "${flags[@]}"; then
    die "$(sync_dump_fail_hint)"
  fi
  finish_dump_file "$output"
}


# Escape hatch: compose exec mysqldump / one-shot mysql client (SYNC_DUMP_ENGINE=mysqldump).
dump_db_via_url_mysqldump() {
  parse_database_url || die "No bundled mysql service and DATABASE_URL is missing. Set DATABASE_URL or keep the mysql service in deploy/compose.yaml."
  if [[ "$DB_HOST" == "mysql" ]]; then
    die "DATABASE_URL host is 'mysql' but the compose mysql service is not available on the source. Start the stack or point DATABASE_URL at the real database host."
  fi
  local img
  img="$(client_image_for_url)"
  log "Dumping external database ${DB_HOST}:${DB_PORT}/${DB_NAME} via ${img} mysqldump (SYNC_DUMP_ENGINE=$(sync_dump_engine); credentials not printed)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN docker run --network host ${img} mysqldump | gzip > ${SNAPSHOT_DIR}/db.sql.gz"
    return
  fi
  docker run --rm --network host --entrypoint sh \
    -e MYSQL_PWD="$DB_PASS" \
    -e DUMP_HOST="$DB_HOST" \
    -e DUMP_PORT="$DB_PORT" \
    -e DUMP_USER="$DB_USER" \
    -e DUMP_DB="$DB_NAME" \
    "$img" \
    -c 'set -eu
      if command -v mariadb-dump >/dev/null; then D=mariadb-dump
      elif command -v mysqldump >/dev/null; then D=mysqldump
      else echo "no dump tool in client image" >&2; exit 1
      fi
      FLAGS="--single-transaction --quick --routines --triggers --events --hex-blob --no-tablespaces --default-character-set=utf8mb4"
      if [ "$D" = mysqldump ]; then FLAGS="$FLAGS --column-statistics=0"; fi
      # shellcheck disable=SC2086
      "$D" -h"$DUMP_HOST" -P"$DUMP_PORT" -u"$DUMP_USER" $FLAGS "$DUMP_DB"' \
    | gzip -c >"${SNAPSHOT_DIR}/db.sql.gz"
  gzip -t "${SNAPSHOT_DIR}/db.sql.gz"
}

dump_db_local_mysqldump() {
  log "Dumping database on this host with mysqldump (SYNC_DUMP_ENGINE=$(sync_dump_engine))"
  if has_mysql_service_local; then
    mysql_up_local
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN ${COMPOSE[*]} exec -T mysql sh -c '<mysqldump|mariadb-dump>' | gzip > ${SNAPSHOT_DIR}/db.sql.gz"
      return
    fi
    "${COMPOSE[@]}" exec -T mysql sh -c "$(mysql_dump_sh)" | gzip -c >"${SNAPSHOT_DIR}/db.sql.gz"
    gzip -t "${SNAPSHOT_DIR}/db.sql.gz"
    return
  fi
  dump_db_via_url_mysqldump
}

dump_db_remote_mysqldump() {
  log "Dumping database on ${SSH_TARGET} (${REMOTE_PATH}) with mysqldump (SYNC_DUMP_ENGINE=$(sync_dump_engine))"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN ssh ${SSH_TARGET} compose exec mysql mysqldump | gzip → ${SNAPSHOT_DIR}/db.sql.gz"
    return
  fi
  if ! remote_bash "${COMPOSE_STR} config --services 2>/dev/null | grep -qx mysql"; then
    die "Remote has no compose mysql service. A remote DATABASE_URL is not dumped from this host (it may not be reachable). Keep bundled mysql, or snapshot on the source: ssh ${SSH_TARGET} 'cd ${REMOTE_PATH} && bash deploy/sync-runtime.sh snapshot --from local --data db'."
  fi
  local dump_q wait_q
  dump_q=$(printf '%q' "$(mysql_dump_sh)")
  wait_q=$(printf '%q' "$(mysql_wait_sh)")
  remote_bash "${COMPOSE_STR} up -d --no-build mysql
${COMPOSE_STR} exec -T mysql sh -c ${wait_q}
${COMPOSE_STR} exec -T mysql sh -c ${dump_q} | gzip -c" >"${SNAPSHOT_DIR}/db.sql.gz"
  if [[ ! -s "${SNAPSHOT_DIR}/db.sql.gz" ]]; then
    die "Remote database dump produced an empty file"
  fi
  gzip -t "${SNAPSHOT_DIR}/db.sql.gz"
}

dump_db_remote_shopware_cli() {
  local img flags_q wait_q
  img="$(sync_dump_image)"
  local -a flags=()
  sync_dump_append_core_flags flags
  flags+=(--host mysql --port 3306)
  flags_q=$(printf '%q ' "${flags[@]}")
  wait_q=$(printf '%q' "$(mysql_wait_sh)")
  log "Dumping database on ${SSH_TARGET} (${REMOTE_PATH}) via shopware-cli project dump"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN ssh ${SSH_TARGET} docker run --rm --network <compose-default> -v ${REMOTE_PATH}:${REMOTE_PATH}:ro -w ${REMOTE_PATH} ${img} $(sync_dump_flags_log /tmp/sw-runtime-dump.sql.gz) --host mysql → ${SNAPSHOT_DIR}/db.sql.gz"
    return
  fi
  if ! remote_bash "${COMPOSE_STR} config --services 2>/dev/null | grep -qx mysql"; then
    die "Remote has no compose mysql service. A remote DATABASE_URL is not dumped from this host (it may not be reachable). Keep bundled mysql, or snapshot on the source: ssh ${SSH_TARGET} 'cd ${REMOTE_PATH} && bash deploy/sync-runtime.sh snapshot --from local --data db'."
  fi
  # Credentials expand on the remote after it sources .env (not interpolated here).
  # --output is a host tempfile bind-mounted into the CLI container (avoids mixing logs with gzip stdout).
  remote_bash "${COMPOSE_STR} up -d --no-build mysql
${COMPOSE_STR} exec -T mysql sh -c ${wait_q}
img=$(printf '%q' "$img")
if ! docker image inspect \$img >/dev/null 2>&1; then
  docker pull \$img || { echo 'Failed to pull shopware-cli image for project dump.' >&2; echo 'Escape hatch: SYNC_DUMP_ENGINE=mysqldump' >&2; exit 1; }
fi
project=\"\${COMPOSE_PROJECT_NAME:-}\"
if [[ -z \"\$project\" && -n \"\${SHOPWARE_SHOP_ID:-}\" && -n \"\${SHOPWARE_DEPLOY_ENV:-}\" ]]; then
  project=\"\${SHOPWARE_SHOP_ID}-\${SHOPWARE_DEPLOY_ENV}\"
fi
net=\"\${project}_default\"
user=\"\${MYSQL_USER:-}\"
pass=\"\${MYSQL_PASSWORD:-}\"
if [[ -z \"\$user\" && -n \"\${MYSQL_ROOT_PASSWORD:-}\" ]]; then
  user=root
  pass=\"\${MYSQL_ROOT_PASSWORD}\"
fi
if [[ -z \"\$user\" ]]; then
  echo 'Cannot dump bundled mysql on the source: set MYSQL_USER or MYSQL_ROOT_PASSWORD in .env' >&2
  exit 1
fi
db=\"\${MYSQL_DATABASE:-shopware}\"
out=\$(mktemp)
trap 'rm -f \"\$out\"' EXIT
chmod 600 \"\$out\"
run=(docker run --rm --network \"\$net\" -v \"\$PWD:\$PWD:ro\" -v \"\$out:\$out\" -w \"\$PWD\" -e HOME=/tmp -e SHOPWARE_CLI_NO_UPDATE_NOTIFICATION=true \$img ${flags_q} --output \"\$out\" --username \"\$user\" --database \"\$db\")
if [[ -n \"\$pass\" ]]; then
  run+=(--password=\"\$pass\")
fi
\"\${run[@]}\" || { echo 'shopware-cli project dump failed on the source' >&2; exit 1; }
cat \"\$out\"" >"${SNAPSHOT_DIR}/db.sql.gz"
  if [[ ! -s "${SNAPSHOT_DIR}/db.sql.gz" ]]; then
    die "Remote shopware-cli project dump produced an empty file"
  fi
  gzip -t "${SNAPSHOT_DIR}/db.sql.gz" || die "Remote dump is not valid gzip (shopware-cli --compression=gzip)."
}

dump_db_local() {
  log "Dumping database on this host"
  assert_dump_engine
  if sync_dump_engine_is_mysqldump; then
    dump_db_local_mysqldump
    return
  fi
  log "Using shopware-cli project dump ($(sync_dump_image))"
  run_shopware_cli_dump_local
}

dump_db_remote() {
  assert_dump_engine
  if sync_dump_engine_is_mysqldump; then
    dump_db_remote_mysqldump
    return
  fi
  dump_db_remote_shopware_cli
}

restore_db_via_url() {
  parse_database_url || die "No bundled mysql service and DATABASE_URL is missing; cannot restore db."
  if [[ "$DB_HOST" == "mysql" ]]; then
    die "DATABASE_URL host is 'mysql' but the compose mysql service is not running here."
  fi
  local img dump
  img="$(client_image_for_url)"
  if [[ -f "${SNAPSHOT_DIR}/db.sql.gz" ]]; then
    dump="${SNAPSHOT_DIR}/db.sql.gz"
  elif [[ -f "${SNAPSHOT_DIR}/db.sql" ]]; then
    dump="${SNAPSHOT_DIR}/db.sql"
  else
    die "No db.sql.gz (or db.sql) in ${SNAPSHOT_DIR}"
  fi
  log "Restoring external database ${DB_HOST}:${DB_PORT}/${DB_NAME} (credentials from DATABASE_URL, not printed)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN gzip -dc ${dump} | docker run ${img} mysql ${DB_NAME}"
    return
  fi
  local decode=(gzip -dc)
  if [[ "$dump" == *.sql && "$dump" != *.gz ]]; then
    decode=(cat)
  fi
  "${decode[@]}" "$dump" | docker run --rm -i --network host --entrypoint sh \
    -e MYSQL_PWD="$DB_PASS" \
    -e DUMP_HOST="$DB_HOST" \
    -e DUMP_PORT="$DB_PORT" \
    -e DUMP_USER="$DB_USER" \
    -e DUMP_DB="$DB_NAME" \
    "$img" \
    -c 'set -eu
      if command -v mariadb >/dev/null; then C=mariadb; else C=mysql; fi
      "$C" -h"$DUMP_HOST" -P"$DUMP_PORT" -u"$DUMP_USER" --max-allowed-packet=1G "$DUMP_DB"'
}

restore_db_local() {
  local dump=""
  if [[ -f "${SNAPSHOT_DIR}/db.sql.gz" ]]; then
    dump="${SNAPSHOT_DIR}/db.sql.gz"
  elif [[ -f "${SNAPSHOT_DIR}/db.sql" ]]; then
    dump="${SNAPSHOT_DIR}/db.sql"
  else
    die "No db.sql.gz (or db.sql) in ${SNAPSHOT_DIR}"
  fi
  log "Restoring database on this host from ${dump}"
  if has_mysql_service_local; then
    mysql_up_local
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN gzip -dc ${dump} | ${COMPOSE[*]} exec -T mysql sh -c '<mysql|mariadb>'"
      return
    fi
    if [[ "$dump" == *.gz ]]; then
      gzip -dc "$dump" | "${COMPOSE[@]}" exec -T mysql sh -c "$(mysql_restore_sh)"
    else
      "${COMPOSE[@]}" exec -T mysql sh -c "$(mysql_restore_sh)" <"$dump"
    fi
    return
  fi
  restore_db_via_url
}
