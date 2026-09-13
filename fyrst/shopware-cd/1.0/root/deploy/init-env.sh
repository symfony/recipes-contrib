#!/usr/bin/env bash
# Finish shop-root .env after shopware-cli project create + Flex.
#
# Flex may append a ###> fyrst/shopware-cd ### block with safe SoT defaults
# (empty SHOPWARE_SHOP_ID, SHOPWARE_DEPLOY_ENV=live, SHOPWARE_DATA_BASE).
# This script fills shop-specific values. It does not overwrite the whole
# file, does not invent MYSQL passwords / APP_URL, and does not put secrets
# in the Flex env block.
#
# Usage (from shop root, or COMPOSE_DIR=shop-root):
#   bash deploy/init-env.sh --shop-id <slug> [--env live] [--vps] …
#
# See deploy/README.md.

set -euo pipefail

case "$-" in
  *x*)
    printf 'ERROR: refusing to run with xtrace (credentials may be in .env)\n' >&2
    exit 1
    ;;
esac

umask 077

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_DIR="${COMPOSE_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

log() { printf '==> %s\n' "$*"; }
err() { printf 'ERROR: %s\n' "$*" >&2; }
die() { err "$@"; exit 1; }

usage() {
  cat <<'EOF'
Usage: bash deploy/init-env.sh [options]

Finish shop-root .env after create + Flex. Merges missing keys from
.env.example, sets shop identity, and can strip create's
COMPOSE_PROJECT_NAME=sw-shop-… line on a VPS.

Does not overwrite the whole .env. Does not invent MYSQL passwords or
APP_URL. Flex env only ships safe defaults (empty shop id).

Options:
  --shop-id <slug>   Required unless SHOPWARE_SHOP_ID is already non-empty
  --env <name>       live | staging | playground | dev  (default: live
                     when unset/empty; existing non-empty value is kept)
  --image <repo>     Set IMAGE (registry/repo). Unset leaves IMAGE as-is
  --vps              Comment out COMPOSE_PROJECT_NAME=… lines (create
                     footgun). Does not leave an empty COMPOSE_PROJECT_NAME=
  --generate-app-secret
                     Set APP_SECRET with openssl rand -hex 32 if empty
  --dry-run          Print the summary; do not write .env
  -h, --help         Show this help

Environment:
  COMPOSE_DIR        Shop checkout (default: parent of deploy/)

Examples:
  bash deploy/init-env.sh --shop-id acme
  bash deploy/init-env.sh --shop-id acme --env live --vps --image ghcr.io/example/acme
  bash deploy/init-env.sh --shop-id acme --generate-app-secret
  bash deploy/init-env.sh --shop-id acme --vps --dry-run
EOF
}

need_value() {
  local flag=$1
  local value=${2:-}
  if [[ -z "$value" || "$value" == --* ]]; then
    die "${flag} requires a value"
  fi
}

SHOP_ID_FLAG=""
ENV_FLAG=""
IMAGE_FLAG=""
VPS=0
GENERATE_SECRET=0
DRY_RUN=0
WORK=""
ORIG=""

cleanup() {
  rm -f "${WORK:-}" "${ORIG:-}"
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    --shop-id)
      need_value "$1" "${2:-}"
      SHOP_ID_FLAG=$2
      shift 2
      ;;
    --shop-id=*)
      SHOP_ID_FLAG="${1#*=}"
      shift
      ;;
    --env)
      need_value "$1" "${2:-}"
      ENV_FLAG=$2
      shift 2
      ;;
    --env=*)
      ENV_FLAG="${1#*=}"
      shift
      ;;
    --image)
      need_value "$1" "${2:-}"
      IMAGE_FLAG=$2
      shift 2
      ;;
    --image=*)
      IMAGE_FLAG="${1#*=}"
      shift
      ;;
    --vps)
      VPS=1
      shift
      ;;
    --generate-app-secret)
      GENERATE_SECRET=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      die "Unknown option: $1 (try --help)"
      ;;
    *)
      die "Unexpected argument: $1 (try --help)"
      ;;
  esac
done

cd "$COMPOSE_DIR" || die "Cannot cd to COMPOSE_DIR=${COMPOSE_DIR}"

ENV_FILE="${COMPOSE_DIR}/.env"
EXAMPLE_FILE="${COMPOSE_DIR}/.env.example"

is_comment_or_blank() {
  [[ "$1" =~ ^[[:space:]]*# ]] || [[ "$1" =~ ^[[:space:]]*$ ]]
}

# Uncommented KEY= assignment (optional export). Prints 1 if present.
env_has_key() {
  local file=$1 key=$2 line
  [[ -f "$file" ]] || return 1
  while IFS= read -r line || [[ -n "$line" ]]; do
    is_comment_or_blank "$line" && continue
    if [[ "$line" =~ ^[[:space:]]*(export[[:space:]]+)?${key}= ]]; then
      return 0
    fi
  done <"$file"
  return 1
}

env_unquote() {
  local v=$1
  if [[ ${#v} -ge 2 && "$v" == \"*\" ]]; then
    v="${v#\"}"
    v="${v%\"}"
  elif [[ ${#v} -ge 2 && "$v" == \'*\' ]]; then
    v="${v#\'}"
    v="${v%\'}"
  fi
  printf '%s' "$v"
}

# Last uncommented assignment wins (Compose / Docker dotenv).
env_get() {
  local file=$1 key=$2 val="" line
  [[ -f "$file" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    is_comment_or_blank "$line" && continue
    if [[ "$line" =~ ^[[:space:]]*(export[[:space:]]+)?${key}=(.*)$ ]]; then
      val="$(env_unquote "${BASH_REMATCH[2]}")"
    fi
  done <"$file"
  printf '%s' "$val"
}

env_set_key() {
  local file=$1 key=$2 value=$3
  local tmp line found=0
  tmp="$(mktemp)"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if is_comment_or_blank "$line"; then
      printf '%s\n' "$line"
      continue
    fi
    if [[ "$line" =~ ^[[:space:]]*(export[[:space:]]+)?${key}= ]]; then
      if [[ "$line" =~ ^[[:space:]]*export[[:space:]]+ ]]; then
        printf 'export %s=%s\n' "$key" "$value"
      else
        printf '%s=%s\n' "$key" "$value"
      fi
      found=1
      continue
    fi
    printf '%s\n' "$line"
  done <"$file" >"$tmp"
  if [[ "$found" -eq 0 ]]; then
    if [[ -s "$tmp" ]] && [[ "$(tail -c 1 "$tmp" 2>/dev/null || true)" != $'\n' ]]; then
      printf '\n' >>"$tmp"
    fi
    printf '%s=%s\n' "$key" "$value" >>"$tmp"
  fi
  mv "$tmp" "$file"
}

validate_shop_id() {
  local slug=$1
  if [[ ! "$slug" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
    die "Invalid --shop-id '${slug}'. Use a lowercase slug (letters, digits, hyphens), e.g. acme."
  fi
}

validate_deploy_env() {
  local name=$1
  case "$name" in
    live | staging | playground | dev) ;;
    *)
      die "Invalid --env '${name}'. Use live, staging, playground, or dev."
      ;;
  esac
}

comment_compose_project_name() {
  local file=$1
  local tmp line n=0
  tmp="$(mktemp)"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*(export[[:space:]]+)?COMPOSE_PROJECT_NAME= ]]; then
      printf '# %s  # commented by deploy/init-env.sh --vps (restore for local project dev)\n' "$line"
      n=$((n + 1))
      continue
    fi
    printf '%s\n' "$line"
  done <"$file" >"$tmp"
  mv "$tmp" "$file"
  printf '%s' "$n"
}

merge_missing_from_example() {
  local example=$1 dest=$2
  local line key header=0
  local -a added=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    is_comment_or_blank "$line" && continue
    if [[ "$line" =~ ^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)= ]]; then
      key="${BASH_REMATCH[2]}"
      if ! env_has_key "$dest" "$key"; then
        if [[ "$header" -eq 0 ]]; then
          printf '\n# --- missing keys merged from .env.example by deploy/init-env.sh ---\n' >>"$dest"
          header=1
        fi
        printf '%s\n' "$line" >>"$dest"
        added+=("$key")
      fi
    fi
  done <"$example"
  if [[ ${#added[@]} -gt 0 ]]; then
    local IFS=,
    printf '%s' "${added[*]}"
  fi
}

if [[ ! -f "$ENV_FILE" && ! -f "$EXAMPLE_FILE" ]]; then
  die "Missing ${ENV_FILE} and ${EXAMPLE_FILE}. Run this from the shop root after Flex copied .env.example (composer require fyrst/shopware-cd), or copy a shop .env into COMPOSE_DIR=${COMPOSE_DIR}."
fi

COPIED=0
if [[ ! -f "$ENV_FILE" ]]; then
  COPIED=1
fi

WORK="$(mktemp)"
ORIG="$(mktemp)"
if [[ -f "$ENV_FILE" ]]; then
  cp "$ENV_FILE" "$WORK"
  cp "$ENV_FILE" "$ORIG"
else
  cp "$EXAMPLE_FILE" "$WORK"
  : >"$ORIG"
fi

MERGED_KEYS=""
if [[ -f "$EXAMPLE_FILE" ]]; then
  MERGED_KEYS="$(merge_missing_from_example "$EXAMPLE_FILE" "$WORK")"
fi

EXISTING_SHOP_ID="$(env_get "$WORK" SHOPWARE_SHOP_ID)"
EXISTING_DEPLOY_ENV="$(env_get "$WORK" SHOPWARE_DEPLOY_ENV)"
EXISTING_APP_SECRET="$(env_get "$WORK" APP_SECRET)"
EXISTING_IMAGE="$(env_get "$WORK" IMAGE)"

SHOP_ID="${SHOP_ID_FLAG:-$EXISTING_SHOP_ID}"
if [[ -z "$SHOP_ID" ]]; then
  die "SHOPWARE_SHOP_ID is empty. Pass --shop-id <slug> (same slug on live, staging, and laptop)."
fi
validate_shop_id "$SHOP_ID"

DEPLOY_ENV="${ENV_FLAG:-$EXISTING_DEPLOY_ENV}"
if [[ -z "$DEPLOY_ENV" ]]; then
  DEPLOY_ENV=live
fi
validate_deploy_env "$DEPLOY_ENV"

if [[ -n "$IMAGE_FLAG" ]]; then
  if [[ "$IMAGE_FLAG" =~ [[:space:]] ]]; then
    die "Invalid --image '${IMAGE_FLAG}' (no whitespace)."
  fi
fi

if [[ "$GENERATE_SECRET" -eq 1 && -z "$EXISTING_APP_SECRET" && "$DRY_RUN" -eq 0 ]]; then
  if ! command -v openssl >/dev/null 2>&1; then
    die "--generate-app-secret needs openssl (openssl rand -hex 32)."
  fi
  NEW_SECRET="$(openssl rand -hex 32)"
  if [[ ${#NEW_SECRET} -ne 64 ]]; then
    die "openssl rand -hex 32 did not return 32 bytes."
  fi
  env_set_key "$WORK" APP_SECRET "$NEW_SECRET"
  GENERATED_SECRET=1
else
  GENERATED_SECRET=0
  if [[ "$GENERATE_SECRET" -eq 1 && -z "$EXISTING_APP_SECRET" && "$DRY_RUN" -eq 1 ]]; then
    GENERATED_SECRET=1
  fi
fi

env_set_key "$WORK" SHOPWARE_SHOP_ID "$SHOP_ID"
env_set_key "$WORK" SHOPWARE_DEPLOY_ENV "$DEPLOY_ENV"
if [[ -n "$IMAGE_FLAG" ]]; then
  env_set_key "$WORK" IMAGE "$IMAGE_FLAG"
fi

VPS_COMMENTED=0
if [[ "$VPS" -eq 1 ]]; then
  VPS_COMMENTED="$(comment_compose_project_name "$WORK")"
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  cp "$WORK" "$ENV_FILE"
  chmod 600 "$ENV_FILE"
fi

# --- summary (never print secret values) -----------------------------------
if [[ "$DRY_RUN" -eq 1 ]]; then
  log "DRY-RUN (no write)  COMPOSE_DIR=${COMPOSE_DIR}"
else
  log "Updated ${ENV_FILE}"
fi

CHANGES=0
if [[ "$COPIED" -eq 1 ]]; then
  printf '    copy .env.example → .env\n'
  CHANGES=1
fi
if [[ -n "$MERGED_KEYS" ]]; then
  printf '    merge missing keys from .env.example: %s\n' "${MERGED_KEYS//,/, }"
  CHANGES=1
fi
if [[ "$EXISTING_SHOP_ID" != "$SHOP_ID" ]]; then
  printf '    set SHOPWARE_SHOP_ID=%s\n' "$SHOP_ID"
  CHANGES=1
fi
if [[ "$EXISTING_DEPLOY_ENV" != "$DEPLOY_ENV" ]]; then
  printf '    set SHOPWARE_DEPLOY_ENV=%s\n' "$DEPLOY_ENV"
  CHANGES=1
fi
if [[ -n "$IMAGE_FLAG" && "$EXISTING_IMAGE" != "$IMAGE_FLAG" ]]; then
  printf '    set IMAGE=%s\n' "$IMAGE_FLAG"
  CHANGES=1
fi
if [[ "$GENERATE_SECRET" -eq 1 ]]; then
  if [[ -n "$EXISTING_APP_SECRET" ]]; then
    printf '    APP_SECRET already set; skipped --generate-app-secret\n'
  elif [[ "$GENERATED_SECRET" -eq 1 ]]; then
    printf '    set APP_SECRET (openssl rand -hex 32; value not printed)\n'
    CHANGES=1
  fi
fi
if [[ "$VPS" -eq 1 ]]; then
  if [[ "$VPS_COMMENTED" -gt 0 ]]; then
    printf '    commented %s COMPOSE_PROJECT_NAME=… line(s) (--vps)\n' "$VPS_COMMENTED"
    CHANGES=1
  else
    printf '    --vps: no uncommented COMPOSE_PROJECT_NAME=… lines\n'
  fi
fi

if [[ "$CHANGES" -eq 0 ]]; then
  printf '    no changes (already up to date)\n'
fi

printf '    left unchanged: MYSQL passwords, APP_URL (fill those by hand)\n'
if [[ "$DRY_RUN" -eq 0 ]]; then
  log "chmod 600 .env"
fi
