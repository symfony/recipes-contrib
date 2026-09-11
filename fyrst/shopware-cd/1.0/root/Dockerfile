# syntax=docker/dockerfile:1.4
#
# Reference / fallback multi-stage image for fyrst.dev shops.
#
# PREFER THE FLEX RECIPE. After `composer require shopware/docker`, Shopware
# installs an official Dockerfile (usually docker/Dockerfile) and keeps it
# current via `composer update shopware/docker`. Point CI at that file
# (DOCKERFILE=docker/Dockerfile) and do not maintain two copies.
#
# Keep this file when:
#   - the Flex recipe is not used yet, or
#   - you need a documented fallback that matches Shopware docs.
#
# Build: shopware-cli project ci (composer install, assets, cleanup, SBOM)
# Runtime: ghcr.io/shopware/docker-base (PHP 8.3, FrankenPHP)
#
# BuildKit secrets (do not bake tokens into layers):
#   --secret id=packages_token,env=SHOPWARE_PACKAGES_TOKEN
#   --secret id=composer_auth,dst=/src/auth.json
#
# Example:
#   docker buildx build --platform linux/amd64 \
#     --secret id=packages_token,env=SHOPWARE_PACKAGES_TOKEN \
#     --secret id=composer_auth,src=auth.json \
#     --build-arg PHP_VERSION=8.3 \
#     -t ghcr.io/example-org/shop-name:local .

ARG PHP_VERSION=8.3

# Shopware currently recommends FrankenPHP over Caddy/Nginx for containers.
# Alternative tags: $PHP_VERSION-caddy | $PHP_VERSION-nginx | $PHP_VERSION-fpm
# Pin a digest in the shop if you need bit-for-bit reproducibility; rolling
# tags like 8.3-frankenphp pick up PHP patch/security rebuilds on --pull.
FROM ghcr.io/shopware/docker-base:${PHP_VERSION}-frankenphp AS base-image
FROM ghcr.io/shopware/shopware-cli:latest-php-${PHP_VERSION} AS shopware-cli

FROM shopware-cli AS build

ADD . /src
WORKDIR /src

# packages_token → env SHOPWARE_PACKAGES_TOKEN for packages.shopware.com
# composer_auth → /src/auth.json (write "{}" in CI when unused)
RUN --mount=type=secret,id=packages_token,env=SHOPWARE_PACKAGES_TOKEN \
    --mount=type=secret,id=composer_auth,dst=/src/auth.json \
    --mount=type=cache,target=/root/.composer \
    --mount=type=cache,target=/root/.npm \
    /usr/local/bin/entrypoint.sh shopware-cli project ci /src

FROM base-image AS final

# uid 82 = www-data in docker-base
COPY --from=build --chown=82 --link /src /var/www/html
