#!/usr/bin/env bash
# Run on the VPS (or via SSH from CI) after the image has been pushed.
# Never builds the image and never compiles themes/assets.
#
# Required env:
#   IMAGE                  registry/repo (e.g. ghcr.io/fyrst-dev/shop-name) — no real defaults
#   IMAGE_TAG              full git SHA (or a rollback tag)
#   SHOPWARE_SHOP_ID       stable shop slug (same on live + staging)
#   SHOPWARE_DEPLOY_ENV    this stack: live | staging | playground | …
# Optional:
#   COMPOSE_DIR            shop checkout (default: repository root next to deploy/)
#   COMPOSE_PROFILES       comma-separated: redis,worker,scheduler  (never include "setup")
#   SMOKE_URL              HTTP URL to probe after up (e.g. http://127.0.0.1:8000)
#   COMPOSE_PROJECT_NAME   scripts/docs only; unset → ${SHOPWARE_SHOP_ID}-${SHOPWARE_DEPLOY_ENV}
#                          create writes COMPOSE_PROJECT_NAME=sw-shop-… into .env; that
#                          overrides Compose name:. On the VPS, remove or comment it out.
#                          This script does not delete it (create owns the local flow).
#   SHOPWARE_DATA_BASE     bind-mount prefix (default: /var/lib/shopware/data)
#   SHOPWARE_DATA_ROOT     bind-mount root (default: ${SHOPWARE_DATA_BASE}/<shop>/<env>)
#   PULL_POLICY            always (default, CI/VPS) | never (same-host tag-and-load / air-gap).
#   SKIP_PULL              1/true → skip `docker compose pull`, set PULL_POLICY=never.
#
# CI-exported IMAGE / IMAGE_TAG / SKIP_PULL / PULL_POLICY always win over .env.
#
# Compose files (shop root as --project-directory):
#   deploy/compose.yaml, deploy/compose.prod.yaml, deploy/compose.vps.yaml
#
# compose run uses --pull never (Compose v5 dropped --no-build from the run
# subcommand; do not pass --build). up uses --no-build.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash deploy/vps-release.sh [--skip-pull]

  --skip-pull   Same-host / air-gap: skip registry pull, PULL_POLICY=never
EOF
}

SKIP_PULL="${SKIP_PULL:-}"
for arg in "$@"; do
  case "$arg" in
    --skip-pull) SKIP_PULL=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage
      exit 1
      ;;
  esac
done

COMPOSE_DIR="${COMPOSE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$COMPOSE_DIR"

env_truthy() {
  local v
  v="$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')"
  [[ "$v" == "1" || "$v" == "true" || "$v" == "yes" || "$v" == "on" ]]
}

CI_IMAGE="${IMAGE:-}"
CI_IMAGE_TAG="${IMAGE_TAG:-}"
CI_SMOKE_URL="${SMOKE_URL:-}"
CI_PROFILES="${COMPOSE_PROFILES:-}"
CI_SKIP_PULL="${SKIP_PULL:-}"
CI_PULL_POLICY="${PULL_POLICY:-}"

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
SMOKE_URL="${CI_SMOKE_URL:-${SMOKE_URL:-}}"
COMPOSE_PROFILES="${CI_PROFILES:-${COMPOSE_PROFILES:-}}"
if [[ -n "${CI_SKIP_PULL:-}" ]]; then
  SKIP_PULL="${CI_SKIP_PULL}"
fi
if [[ -n "${CI_PULL_POLICY:-}" ]]; then
  PULL_POLICY="${CI_PULL_POLICY}"
fi

# Compose interpolates SHOPWARE_SHOP_ID + SHOPWARE_DEPLOY_ENV from .env
# (optional SHOPWARE_DATA_BASE). Derive COMPOSE_PROJECT_NAME / SHOPWARE_DATA_ROOT
# for scripts when only shop id + deploy env are set.
: "${SHOPWARE_SHOP_ID:?Set SHOPWARE_SHOP_ID in .env (stable shop slug, same on live/staging/laptop)}"
: "${SHOPWARE_DEPLOY_ENV:?Set SHOPWARE_DEPLOY_ENV in .env (live|staging|playground|dev)}"
SHOPWARE_DATA_BASE="${SHOPWARE_DATA_BASE:-/var/lib/shopware/data}"
derived_project="${SHOPWARE_SHOP_ID}-${SHOPWARE_DEPLOY_ENV}"
if [[ -z "${COMPOSE_PROJECT_NAME:-}" ]]; then
  COMPOSE_PROJECT_NAME="${derived_project}"
elif [[ "$COMPOSE_PROJECT_NAME" != "$derived_project" ]]; then
  echo "WARNING: COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} is set and overrides Compose name: (${derived_project})." >&2
  echo "WARNING: shopware-cli project create writes COMPOSE_PROJECT_NAME=sw-shop-… into .env for local project dev." >&2
  echo "WARNING: On the VPS, remove or comment out that line so the project name is ${derived_project}." >&2
  echo "WARNING: This script does not delete it (create owns the local flow)." >&2
fi
if [[ -z "${SHOPWARE_DATA_ROOT:-}" ]]; then
  SHOPWARE_DATA_ROOT="${SHOPWARE_DATA_BASE}/${SHOPWARE_SHOP_ID}/${SHOPWARE_DEPLOY_ENV}"
fi

if env_truthy "${SKIP_PULL:-}"; then
  PULL_POLICY=never
  SKIP_PULL=1
else
  PULL_POLICY="$(printf '%s' "${PULL_POLICY:-always}" | tr '[:upper:]' '[:lower:]')"
  if [[ "$PULL_POLICY" == "never" ]]; then
    SKIP_PULL=1
  else
    SKIP_PULL=0
  fi
fi

: "${IMAGE:?Set IMAGE to the registry repository}"
: "${IMAGE_TAG:?Set IMAGE_TAG to the git SHA (or previous tag for rollback)}"

export IMAGE IMAGE_TAG SHOPWARE_SHOP_ID SHOPWARE_DEPLOY_ENV SHOPWARE_DATA_BASE PULL_POLICY SKIP_PULL
if [[ -n "${COMPOSE_PROJECT_NAME:-}" ]]; then
  export COMPOSE_PROJECT_NAME
fi
if [[ -n "${SHOPWARE_DATA_ROOT:-}" ]]; then
  export SHOPWARE_DATA_ROOT
fi

touch .env.prod

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
    echo "COMPOSE_PROFILES must not include setup (the script runs that profile itself)" >&2
    exit 1
  fi
  PROFILE_ARGS+=(--profile "$p")
done

has_service() {
  "${COMPOSE[@]}" "${PROFILE_ARGS[@]}" config --services 2>/dev/null | grep -qx "$1"
}

up_pull=()
if [[ "${SKIP_PULL}" == "1" ]]; then
  up_pull=(--pull never)
fi

echo "==> Deploying ${IMAGE}:${IMAGE_TAG} from ${COMPOSE_DIR} (compose run --pull never, up --no-build)"

if [[ -f .deployed-tag ]]; then
  cp .deployed-tag .previous-tag
  echo "==> Previous tag: $(cat .previous-tag)"
fi

if [[ "${SKIP_PULL}" == "1" ]]; then
  echo "==> Skipping registry pull (SKIP_PULL=1 / PULL_POLICY=${PULL_POLICY}); using images already on this host"
else
  echo "==> Pulling images"
  "${COMPOSE[@]}" "${PROFILE_ARGS[@]}" pull
fi

if has_service mysql; then
  echo "==> Starting mysql"
  "${COMPOSE[@]}" up -d --no-build ${up_pull[@]+"${up_pull[@]}"} mysql
fi

if has_service redis; then
  echo "==> Starting redis"
  "${COMPOSE[@]}" --profile redis up -d --no-build ${up_pull[@]+"${up_pull[@]}"} redis
fi

echo "==> One-shot setup (shopware-deployment-helper, skip theme/assets)"
"${COMPOSE[@]}" --profile setup run --rm --pull never setup

echo "==> Recreating web (no build)"
"${COMPOSE[@]}" up -d --no-build ${up_pull[@]+"${up_pull[@]}"} --remove-orphans web

if [[ ${#PROFILE_ARGS[@]} -gt 0 ]]; then
  echo "==> Starting extra profiles: ${COMPOSE_PROFILES}"
  "${COMPOSE[@]}" "${PROFILE_ARGS[@]}" up -d --no-build ${up_pull[@]+"${up_pull[@]}"}
fi

printf '%s\n' "$IMAGE_TAG" > .deployed-tag

if [[ -n "${SMOKE_URL:-}" ]]; then
  echo "==> Smoke ${SMOKE_URL}"
  ok=0
  for _ in $(seq 1 30); do
    if command -v curl >/dev/null 2>&1 && curl -fsS "$SMOKE_URL" >/dev/null; then
      echo "==> Smoke OK"
      ok=1
      break
    fi
    sleep 2
  done
  if [[ "$ok" -ne 1 ]]; then
    echo "Smoke check failed for ${SMOKE_URL}" >&2
    exit 1
  fi
fi

echo "==> Deploy finished ${IMAGE}:${IMAGE_TAG}"
