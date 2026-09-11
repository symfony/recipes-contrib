# fyrst.dev — primary deploy: Docker Compose on a VPS
#
# Locked process: https://app.clickup.com/90151931897/docs/2kyqjkzt-915
# Image is built in CI (`shopware-cli project ci`). This host only pulls and runs it.

## Model

- **web** — Shopware image (`ghcr.io/shopware/docker-base` + project artifact), port 8000
- **setup** — one-shot `shopware-deployment-helper` (profile `setup`)
- **mysql** — bundled in Compose, or delete the service and point `DATABASE_URL` at DBaaS
- **redis** / **worker** / **scheduler** — optional Compose profiles

## One-time VPS bootstrap

1. Install Docker Engine + Compose plugin. Do not install Shopware or PHP on the host.
2. Checkout this shop repo (read-only deploy key) to a path such as `/opt/shopware/<shop>`.
   That path is `VPS_PATH` in CI.
3. Copy `.env.example` → `.env` and fill runtime secrets. `chmod 600 .env`.
4. Create `.env.prod` (may be empty) so `deploy/compose.prod.yaml` can mount it.
5. Set `IMAGE` to the registry repository CI pushes (example: `ghcr.io/fyrst-dev/shop-name`).
6. `docker login` to that registry on the VPS (or use a credential helper / `~/.docker/config.json`).
7. Put a reverse proxy in front of `HTTP_PORT` (TLS). Do not expose MySQL.
8. Store the previous image tag for rollback (the release script writes `.deployed-tag` / `.previous-tag`).

## CD sequence (what CI runs)

`deploy/vps-release.sh` (from the checkout at `VPS_PATH`):

1. Record the currently deployed tag as `.previous-tag`
2. `docker compose … pull` the new `:git-sha`
3. Start bundled `mysql` (if present) and optional profiles
4. Run setup **once**:

   ```bash
   vendor/bin/shopware-deployment-helper run \
     --skip-theme-compile \
     --skip-assets-install
   ```

   (via `docker compose --profile setup run --rm setup`)
5. Recreate `web` with `--no-build`
6. Optional `SMOKE_URL` check

Manual equivalent:

```bash
export IMAGE=ghcr.io/example-org/shop-name   # TODO
export IMAGE_TAG=<full-git-sha>

cd /opt/shopware/<shop>                      # TODO: VPS_PATH
git fetch --quiet origin
git checkout --quiet "$IMAGE_TAG"

bash ./deploy/vps-release.sh
```

Compose files used (from the shop root, with `--project-directory .`):

- `deploy/compose.yaml`
- `deploy/compose.prod.yaml`
- `deploy/compose.vps.yaml`
- `deploy/sync-runtime.sh` / `deploy/sync.env.example` — live → lower runtime copy (no S3)

shopware-cli project create owns shop-root `compose.yaml` (local). Do not point CD at that file.

## Why skip theme/assets on deploy

`shopware-cli project ci` already compiled them into the image. Rebuilding on the VPS is an anti-pattern (time + drift).

## Fresh install vs update

The helper detects a fresh database vs an existing shop:

- **Fresh:** schema, admin user from `INSTALL_ADMIN_*`, sales channel from `APP_URL` / `SALES_CHANNEL_URL`, extensions
- **Update:** migrations when the Shopware version changed, extension sync, hooks

## Rollback

```bash
export IMAGE_TAG=$(cat .previous-tag)
bash ./deploy/vps-release.sh
```

Keep the previous image physically on the host (`docker image prune` with care).

## Runtime data sync (VPS, no S3)

DB + media/files are **not** in git and **not** in the app image. They live in MySQL and in Docker named volumes on the VPS (`files`, `media`, `thumbnail`, `theme`, `sitemap`).

`deploy/sync-runtime.sh` copies that runtime data **live → lower** (staging / playground / dev) with **SSH + mysqldump + volume tars**. There is no S3/MinIO path in this recipe.

| Command | What it does |
| --- | --- |
| `sync --from live` | Pull dump + volumes from a higher env onto **this** host |
| `snapshot` | Write a local snapshot under `SYNC_SNAPSHOT_DIR` |
| `restore --snapshot <id>` | Restore a local snapshot onto this host |

**Direction:** run `sync` on the consumer (cron on staging). Never auto-push into live. `SYNC_ENV=live` refuses `sync`.

```bash
# on staging
cd /opt/shopware/<shop>
cp deploy/sync.env.example deploy/sync.env   # set SYNC_SSH_* , SYNC_ENV=staging
chmod 600 deploy/sync.env

bash deploy/sync-runtime.sh sync --from live --data all
```

`--data all` (default) is DB + volumes; use `db` or `volumes` to limit. Both shops need this script in `deploy/` (Flex-update live as well as staging).

Cron (staging):

```cron
15 2 * * * cd /opt/shopware/staging && bash deploy/sync-runtime.sh sync --from live --data all
```

Local snapshot / restore (same host, still no S3):

```bash
bash deploy/sync-runtime.sh snapshot --data all
bash deploy/sync-runtime.sh restore --snapshot <id> --data all
```

After a live DB lands on staging, `.env` is left alone. Optional `SYNC_REWRITE_FROM_URL` / `SYNC_REWRITE_TO_URL` rewrites `sales_channel_domain.url`. Then set staging `APP_URL` as usual.

## Required CI secrets (Compose path)

See comments at the top of `.github/workflows/cd.yaml` and `.gitlab-ci.yaml`.

Typical: `SSH_PRIVATE_KEY`, `VPS_HOST`, `VPS_USER`, `VPS_PATH`, `SSH_KNOWN_HOSTS`.
