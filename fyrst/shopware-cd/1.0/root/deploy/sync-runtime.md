# Runtime data sync (VPS, bind mounts, no object storage)

Pull **database + Shopware runtime files** from another VPS onto this one. Typical direction: **live → staging / playground / dev**.

This is **not** part of image CD. `deploy/vps-release.sh` is unchanged (pull image, setup helper, recreate `web`). Runtime files stay out of git and out of the Shopware app image (`/.dockerignore` already excludes `/deploy` and `/var`).

Object storage (S3 and similar) is **out of scope** for this VPS path. Transfer is SSH + `mysqldump` + **rsync of host bind-mount directories**. Named-volume tars are only a fallback (no `rsync` on the consumer, or a leftover Docker volume from an older stack).

## What is copied

Default `--data all` (same as omitting `--data`):

| Item | Mechanism |
| --- | --- |
| `db` | Logical SQL dump from the bundled compose `mysql` service (or `DATABASE_URL`) |
| `media` `files` `thumbnail` `theme` `sitemap` | Bind mounts under `${SHOPWARE_DATA_ROOT:-/var/lib/shopware/data}/<name>` |

Not copied: `mysql_data` / `redis_data` named volumes (use `db` for SQL; Redis is ephemeral for this recipe). Do not put dumps in git.

Set `SHOPWARE_DATA_ROOT` in shop-root `.env` when several shops share a host. If the **source** uses a non-default root, set `SYNC_REMOTE_DATA_ROOT` or `SYNC_LIVE_DATA_ROOT` in `deploy/sync.env`.

## Host packages

On **every** VPS that snapshots or restores:

- Docker Engine + Compose v2 plugin
- bash
- OpenSSH client
- gzip
- **rsync** (primary copy path for bind-mount dirs)

The SSH user must be able to run `docker` (typically the `docker` group) so restore can `chown` uid 82 via a one-shot Alpine container.

## One-time setup (consumer)

On staging (or playground/dev), not on live:

1. Copy `deploy/sync.env.example` → `deploy/sync.env` and `chmod 600 deploy/sync.env`.
2. Set `SYNC_ENV=staging` (or `playground` / `dev`). **Never** set `SYNC_ENV=live` on a host you restore onto.
3. Fill `SYNC_SSH_*` and `SYNC_SSH_PATH` for the source (live checkout, e.g. `/opt/shopware/live`).
4. Install an SSH key that can log in to live **without a passphrase** (cron). Pin `known_hosts`.
5. Confirm shop-root `.env` has `IMAGE` and `SHOPWARE_DATA_ROOT` (compose interpolation). Sync does not read secrets from the script itself.

Do not commit `deploy/sync.env` (add it to the shop `.gitignore`; that file is owned by `shopware-cli project create`).

## Commands

Run from the **shop root** (the script `cd`s to the parent of `deploy/`):

```bash
bash deploy/sync-runtime.sh sync --from live --data all
bash deploy/sync-runtime.sh snapshot --data all
bash deploy/sync-runtime.sh restore --snapshot <id> --data all
```

| Flag | Meaning |
| --- | --- |
| `--from <env>` | Source for `sync` (e.g. `live`). Uses `SYNC_SSH_*` / `SYNC_LIVE_*` |
| `--data all\|db\|volumes` | Default `all`. `volumes` means the bind-mount dirs, not `mysql_data` |
| `--volume <name>` | Single dir for `export --data volumes` (`files`, `media`, …) |
| `--snapshot <id>` | Snapshot directory name under `SYNC_SNAPSHOT_DIR` |
| `--yes` | Skip the overwrite prompt |

### Cron (consumer)

```cron
15 2 * * * cd /opt/shopware/staging && bash deploy/sync-runtime.sh sync --from live --data all
```

Overlapping runs are blocked with `flock`.

## After restore

- The script tries `bin/console cache:clear` via compose `web` and **does not fail** if that errors.
- Optional `SYNC_REWRITE_FROM_URL` / `SYNC_REWRITE_TO_URL` rewrites `sales_channel_domain.url`.
- Bind-mount dirs are `chown -R 82:82` after copy so `www-data` in the Shopware image can write.

## Safety

- `sync` **refuses** `SYNC_ENV=live` / `prod` / `production`. Convention is pull-only onto the lower env.
- `restore` onto live is refused unless `SYNC_ALLOW_LIVE_RESTORE=1` (disaster recovery).
- Dumps contain customer data: `umask` is not forced here; keep `SYNC_SNAPSHOT_DIR` mode `700` on the host.

## Named-volume leftover

If a host still has `shopware_media` (etc.) from an older recipe and the bind-mount directory is missing, snapshot/export will tar that named volume once. New stacks use bind mounts only; do not add `files`/`media`/… back as named volumes in `deploy/compose.yaml`.

## Local `project dev` (laptop)

Do **not** run `deploy/sync-runtime.sh` on a laptop. Local CLI compose bind-mounts the shop tree, not `SHOPWARE_DATA_ROOT`.

```bash
bash deploy/sync-runtime-local.sh --from live --data all
# optional: --delete  --dry-run
shopware-cli project console cache:clear
```

| Live VPS (`SHOPWARE_DATA_ROOT`, default `/var/lib/shopware/data`) | Local project |
| --- | --- |
| `.../files` | `files/` |
| `.../media` | `public/media/` |
| `.../thumbnail` | `public/thumbnail/` |
| `.../theme` | `public/theme/` |
| `.../sitemap` | `public/sitemap/` |

`--from` defaults the SSH host to that alias (`Host live` in `~/.ssh/config`). Optional `deploy/sync.env` / `SYNC_LIVE_*` / `SYNC_REMOTE_DATA_ROOT` match `sync-runtime.sh`. `--delete` is off unless passed (keeps local-only uploads). Database copy is out of scope here.
