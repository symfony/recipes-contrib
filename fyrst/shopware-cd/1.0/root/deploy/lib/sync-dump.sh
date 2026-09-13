#!/usr/bin/env bash
# shopware-cli project dump helpers. Sourced by deploy/sync-runtime.sh.
# Safe to source from tests (no side effects).
#
# Production Shopware app images (compose service `web`) do not ship
# shopware-cli. Sync/backup dumps run a one-shot container from this pinned
# official image, attached to the Compose network (hostname `mysql`) with the
# shop root mounted so `.env` / `.shopware-project.yml` are visible.
#
# Pin: ghcr.io/shopware/shopware-cli:0.18.4
#   Native dump (not mysqldump). Docs:
#   https://developer.shopware.com/docs/products/tools/cli/project-commands/mysql-dump.html
# Override with SYNC_SHOPWARE_CLI_IMAGE. Escape hatch: SYNC_DUMP_ENGINE=mysqldump

# Official CLI image used at CI build time; same registry as Shopware docs.
SYNC_DUMP_SHOPWARE_CLI_IMAGE_DEFAULT="ghcr.io/shopware/shopware-cli:0.18.4"
