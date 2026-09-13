#!/usr/bin/env bash
# Logging + small CLI helpers for deploy/sync-runtime.sh.
# Safe to source from tests (no side effects).

log() { printf '==> %s\n' "$*"; }
err() { printf 'ERROR: %s\n' "$*" >&2; }
die() { err "$@"; exit 1; }

lower_s() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

need_value() {
  local flag=$1
  local value=${2:-}
  if [[ -z "$value" || "$value" == --* ]]; then
    die "${flag} requires a value"
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

require_cmd() {
  local c=$1
  if ! command -v "$c" >/dev/null 2>&1; then
    die "Missing command '${c}'. Install docker, bash, openssh-client, gzip, and rsync on this host."
  fi
}
