#!/usr/bin/env bash
# Snapshot / restore / sync Shopware runtime data between VPS environments.
#
# Unidirectional pull: run this on the CONSUMER (staging, playground, dev) with
# `--from <source>`. Database + bind-mounted upload trees stay on the hosts
# (SQL dump + rsync). Source of truth is SHOPWARE_SHOP_ID + SHOPWARE_DEPLOY_ENV
# (same as deploy/compose.yaml). Default root:
#   $SHOPWARE_DATA_BASE/$SHOPWARE_SHOP_ID/$SHOPWARE_DEPLOY_ENV
#   e.g. /var/lib/shopware/data/acme/live
# COMPOSE_PROJECT_NAME / SHOPWARE_DATA_ROOT are optional; this script derives
# them when unset and prefers them when set. Compose does not require them.
# Object storage (S3 and similar) is out of scope for this VPS path.
#
# Does not call deploy/vps-release.sh and does not change release behaviour.
#
# Do not run with `bash -x` — DATABASE_URL / MYSQL_* may be in the environment.
#
# Required on each host: docker (Compose plugin), bash, OpenSSH client, gzip.
# rsync is required for incremental bind-mount sync (tar is the fallback).
# DB dumps use `shopware-cli project dump` via a one-shot container
# (ghcr.io/shopware/shopware-cli:0.18.4). The compose `web` image does not
# ship shopware-cli. Restore still uses the MySQL/MariaDB client.
#
# Implementation lives in deploy/lib/ (this file parses flags and dispatches).
# Cron and operators still call this script — not the libs.
#
# Usage: deploy/sync-runtime.sh <snapshot|restore|sync> [options]
# See deploy/sync-runtime.md and deploy/sync.env.example.

set -euo pipefail

case "$-" in
  *x*)
    printf 'ERROR: refusing to run with xtrace (credentials may be in the environment)\n' >&2
    exit 1
    ;;
esac

umask 077

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/sync.sh
source "${SCRIPT_DIR}/lib/sync.sh"

sync_cli_defaults

usage() {
  cat <<'EOF'
Usage: deploy/sync-runtime.sh <command> [options]

Commands:
  snapshot   Dump DB and/or copy bind-mount trees into --snapshot-dir
  restore    Load --snapshot-dir into this host's DB and/or SHOPWARE_DATA_ROOT
  sync       Pull from --from then apply locally (cron path: rsync trees + DB)
  help       Show this help

Options:
  --from <alias>         Source host. "local" = this machine (default for
                         snapshot). Any other alias uses SSH (see env below).
  --data <list>|all      Comma-separated subset, or "all".
                         Default: db,media,files,thumbnail,theme,sitemap
                         (not mysql_data / redis_data — use db for SQL)
  --snapshot-dir <dir>   Work directory (default: <shop>/var/runtime-sync)
  --dry-run              Print actions; do not dump, copy, or restore
  --skip-db              Drop db from --data
  --skip-volumes         Drop files/media/thumbnail/theme/sitemap from --data

Environment (no secrets in this script; see deploy/sync.env.example):
  SYNC_ENV               Consumer name. restore/sync refuse SYNC_ENV=live
                         and SHOPWARE_DEPLOY_ENV=live (also refused when the
                         checkout directory is named live) unless
                         SYNC_ALLOW_LIVE_RESTORE=1 (backup DR only)
  SHOPWARE_SHOP_ID       Stable shop slug (required on VPS)
  SHOPWARE_DEPLOY_ENV    This host's stack role (live|staging|playground|dev)
  SHOPWARE_DATA_BASE     Prefix helper (default /var/lib/shopware/data)
  SHOPWARE_DATA_ROOT     Optional bind-mount root for this script. Unset →
                         $SHOPWARE_DATA_BASE/$SHOPWARE_SHOP_ID/$SHOPWARE_DEPLOY_ENV
                         (Compose interpolates that formula itself; it does
                         not require this variable)
  SYNC_DATA_ROOT         Override for this host (else SHOPWARE_DATA_ROOT / derived)
  SYNC_REMOTE_DATA_ROOT  Bind-mount root on the SSH source. Unset →
                         $SHOPWARE_DATA_BASE/$SHOPWARE_SHOP_ID/$SYNC_SOURCE_ENV
  SYNC_SOURCE_ENV        Remote env directory (default: --from alias, else live)
  SYNC_SSH_HOST          Source hostname (default: the --from alias, which
                         may be an ~/.ssh/config Host)
  SYNC_SSH_USER          SSH user
  SYNC_SSH_PORT          SSH port (default 22)
  SYNC_SSH_KEY           Identity file
  SYNC_REMOTE_PATH       Shop checkout on the source (required for SSH)
  SYNC_APP_URL           This environment's public URL (reminder after restore
                         when rewrite is off)
  SYNC_REWRITE_APP_URL   Opt-in: after DB restore, run
                         fyrst:sales-channel:rewrite-urls (origin replace,
                         path kept). Example: https://staging.example.com
  SYNC_REWRITE_URL_MAP   Opt-in old=new[,old=new] prefix map (longest match first)
  SYNC_POST_RESTORE_CMD  Optional shell command after restore (non-fatal)
  SYNC_ARCHIVE_IMAGE     Image used to tar trees if rsync cannot (default alpine:3.20)
  SYNC_SHOPWARE_CLI_IMAGE One-shot dump image (default ghcr.io/shopware/shopware-cli:0.18.4)
  SYNC_DUMP_ENGINE       shopware-cli (default) or mysqldump (escape hatch)
  SYNC_DUMP_CLEAN        1 (default) adds --clean; 0 keeps cart/messenger/log rows
  SYNC_DUMP_ANONYMIZE    0 (default); 1 adds --anonymize
  SYNC_DUMP_QUICK        1 (default) adds --quick; 0 opts out
  COMPOSE_DIR            Shop root (default: parent of deploy/)
  COMPOSE_PROJECT_NAME   Optional for this script. Unset →
                         ${SHOPWARE_SHOP_ID}-${SHOPWARE_DEPLOY_ENV}
                         (Compose interpolates that in name:; it does not
                         require this variable)

Per-alias overrides (example --from live): SYNC_LIVE_SSH_HOST, SYNC_LIVE_SSH_USER,
SYNC_LIVE_SSH_PORT, SYNC_LIVE_SSH_KEY, SYNC_LIVE_REMOTE_PATH, SYNC_LIVE_DATA_ROOT.

Cron (run on staging, pull from live):

  15 2 * * * cd /opt/shopware/acme-staging && bash deploy/sync-runtime.sh sync --from live --data all

Compose files (same as deploy/vps-release.sh, from shop root):
  docker compose --env-file .env -f deploy/compose.yaml -f deploy/compose.prod.yaml -f deploy/compose.vps.yaml
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    snapshot | restore | sync | help | -h | --help)
      if [[ "$1" == help || "$1" == -h || "$1" == --help ]]; then
        COMMAND="help"
      else
        COMMAND=$1
      fi
      shift
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
    --snapshot-dir)
      need_value "$1" "${2:-}"
      SNAPSHOT_DIR=$2
      shift 2
      ;;
    --snapshot-dir=*)
      SNAPSHOT_DIR="${1#*=}"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --skip-db)
      SKIP_DB=1
      shift
      ;;
    --skip-volumes)
      SKIP_VOLUMES=1
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

if [[ -z "$COMMAND" ]]; then
  usage
  die "Missing command (snapshot, restore, or sync)"
fi

if [[ "$COMMAND" == "help" ]]; then
  usage
  exit 0
fi

sync_bootstrap

case "$COMMAND" in
  snapshot) do_snapshot ;;
  restore) do_restore ;;
  sync) do_sync ;;
  *) die "Unknown command: ${COMMAND}" ;;
esac
