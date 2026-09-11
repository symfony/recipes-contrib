# Optional deploy: managed container host

Same Shopware **image** as the Compose/VPS path. Do **not** add a second Dockerfile.

Locked process: [Shopware Create & Continuous Deploy](https://app.clickup.com/90151931897/docs/2kyqjkzt-915)

## When to use

The platform starts/restarts containers for you (managed Kubernetes-like runtimes, PaaS-style hosts, mittwald-style container hosting, etc.). CI still:

1. Builds with `shopware-cli project ci` in the multi-stage Dockerfile
2. Pushes `:sha` / `:latest` / `:semver`
3. Runs Deployment Helper as a one-shot/setup job against that image

## What changes

Only the **deploy job** (and maybe which registry you push to):

- Push to the host’s registry **or** let the host pull from yours
- Trigger their deploy API / CLI / UI instead of SSH + Compose
- Map runtime env (`APP_URL`, `DATABASE_URL`, `APP_SECRET`, `INSTALL_ADMIN_*`) in the host’s secret store

## CI switch

Use **`DEPLOY_TARGET`** (repository variable, not a secret):

| Value | Deploy job |
| --- | --- |
| unset / `compose` | Primary: SSH + Compose (`deploy/vps-release.sh`) |
| `managed` | Skip Compose SSH; run the managed job instead |

(`DEPLY_TARGET` is a typo — do not use it.)

GitHub: Actions variable `DEPLOY_TARGET`. GitLab: CI/CD variable `DEPLOY_TARGET`.

## What to fill in per host (TODOs)

- [ ] Registry URL the platform pulls from
- [ ] Deploy token / kubeconfig / host CLI credentials (CI secret)
- [ ] How to run the one-shot setup command with the **same** flags:

  ```bash
  vendor/bin/shopware-deployment-helper run \
    --skip-theme-compile \
    --skip-assets-install
  ```

- [ ] Health/smoke URL after rollout
- [ ] Rollback: redeploy the previous `:sha` tag

The managed jobs in `.github/workflows/cd.yaml` and `.gitlab-ci.yaml` are **stubs**: they fail with a clear message until you replace the script with the host’s CLI. That is intentional — do not copy a fake happy-path.

## Keep identical across hosts

- Dockerfile / `PHP_VERSION=8.3`
- `.shopware-project.yaml`
- Image naming and tags
- Setup command (deployment helper + skip flags)
- Build-time secrets (`SHOPWARE_PACKAGES_TOKEN`, Composer auth)
