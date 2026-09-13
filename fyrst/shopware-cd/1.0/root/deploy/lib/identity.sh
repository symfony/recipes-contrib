#!/usr/bin/env bash
# Shared Shopware SoT path formulas (shop id, deploy env, data root, project name).
# Sourced by deploy/lib/vps-common.sh and deploy/sync-runtime.sh.
# Safe to source from tests (no side effects beyond DEFAULT_DATA_BASE).

DEFAULT_DATA_BASE="${DEFAULT_DATA_BASE:-/var/lib/shopware/data}"

identity_derived_data_root() {
  local shop_id=$1
  local deploy_env=$2
  printf '%s/%s/%s\n' "${SHOPWARE_DATA_BASE:-$DEFAULT_DATA_BASE}" "$shop_id" "$deploy_env"
}

identity_derived_project_name() {
  printf '%s-%s\n' "$1" "$2"
}

load_env_file() {
  local f=$1
  if [[ -f "$f" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$f"
    set +a
  fi
}
