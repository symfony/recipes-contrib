#!/usr/bin/env bash
# SSH / remote_bash helpers for deploy/sync-runtime.sh.
# Safe to source from tests (no side effects).

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

resolve_source() {
  if [[ "$FROM_LC" == "local" || "$FROM_LC" == "this" ]]; then
    SOURCE_IS_LOCAL=1
    FROM="local"
    return
  fi

  SOURCE_IS_LOCAL=0
  local key host user port keyfile specific_dr
  key="$(alias_key "$FROM")"

  host="$(pick_alias_env "$key" SSH_HOST)"
  user="$(pick_alias_env "$key" SSH_USER)"
  port="$(pick_alias_env "$key" SSH_PORT)"
  keyfile="$(pick_alias_env "$key" SSH_KEY)"
  REMOTE_PATH="$(pick_alias_env "$key" REMOTE_PATH)"
  specific_dr="SYNC_${key}_DATA_ROOT"
  REMOTE_DATA_ROOT="${!specific_dr:-${SYNC_REMOTE_DATA_ROOT:-}}"

  if [[ -z "$host" ]]; then
    host=$FROM
  fi
  SYNC_SSH_HOST=$host
  SYNC_SSH_USER=$user
  SYNC_SSH_PORT="${port:-22}"
  SYNC_SSH_KEY=$keyfile

  if [[ -z "${REMOTE_PATH}" ]]; then
    die "SYNC_REMOTE_PATH (or SYNC_${key}_REMOTE_PATH) is required for --from ${FROM}. Set it in deploy/sync.env (see deploy/sync.env.example)."
  fi

  if [[ -n "$SYNC_SSH_USER" ]]; then
    SSH_TARGET="${SYNC_SSH_USER}@${host}"
  else
    SSH_TARGET=$host
  fi
}


# Pipe a script to remote bash after cd + sourcing the source shop's env files.
# $1 is executed on the remote as-is (no second local expansion).
remote_bash() {
  local payload remote_export
  # Quoted so IMAGE/IMAGE_TAG expand on the remote after it sources .env.
  # shellcheck disable=SC2016
  remote_export='export IMAGE="${IMAGE:-}" IMAGE_TAG="${IMAGE_TAG:-latest}"'
  payload="$(
    printf '%s\n' \
      'set -euo pipefail' \
      "cd $(printf '%q' "$REMOTE_PATH")" \
      'if [[ -f .env ]]; then set -a; source .env; set +a; fi' \
      'if [[ -f .env.prod ]]; then set -a; source .env.prod; set +a; fi' \
      "$remote_export" \
      "$1"
  )"
  printf '%s\n' "$payload" | "${SSH_CMD[@]}" "$SSH_TARGET" bash -s
}

probe_ssh() {
  if [[ "$SOURCE_IS_LOCAL" -eq 1 ]]; then
    return
  fi
  log "Probing SSH ${SSH_TARGET}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN ${SSH_CMD[*]} ${SSH_TARGET} true"
    return
  fi
  if ! "${SSH_CMD[@]}" -o ConnectTimeout=15 "$SSH_TARGET" true; then
    die "SSH to ${SSH_TARGET} failed (BatchMode, no password prompts). Check SYNC_SSH_HOST/USER/PORT/KEY and known_hosts."
  fi
}

remote_dir_exists() {
  local p=$1
  remote_bash "test -d $(printf '%q' "$p")"
}

sync_init_ssh_cmd() {
  SSH_CMD=(ssh -o BatchMode=yes)
  if [[ "$SOURCE_IS_LOCAL" -eq 0 ]]; then
    SSH_CMD+=(-p "${SYNC_SSH_PORT:-22}")
    if [[ -n "${SYNC_SSH_KEY:-}" ]]; then
      SSH_CMD+=(-o IdentitiesOnly=yes -i "${SYNC_SSH_KEY}")
    fi
  fi
}
