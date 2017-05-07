# see https://github.com/dkarlovi/symfony-flex-docker

APP_RUNNER_ID=82

docker-start:
	docker-compose -f ./docker-compose.yaml -f ./.infra/docker-compose/docker-compose.$(APP_ENV).yaml up -d
.PHONY: docker-up

docker-stop:
	docker-compose down
.PHONY: docker-down

docker-start-dev:
	docker-compose -f ./docker-compose.yaml -f ./.infra/docker-compose/docker-compose.dev.yaml up -d
.PHONY: docker-start-dev

docker-start-prod:
	docker-compose -f ./docker-compose.yaml -f ./.infra/docker-compose/docker-compose.prod.yaml up -d
.PHONY: docker-start-prod

docker-start-test:
	docker-compose -f ./docker-compose.yaml -f ./.infra/docker-compose/docker-compose.test.yaml up -d
.PHONY: docker-start-test

docker-build:
	docker-compose build
.PHONY: docker-build

docker-pull:
	docker-compose pull
.PHONY: docker-pull

docker-push:
	docker-compose push
.PHONY: docker-push

docker-logs:
	docker-compose logs -f
.PHONY: docker-logs

docker-init:
	mkdir -p                            var/cache var/logs var/sessions
	setfacl -dRm          m:rwX         var/cache var/logs var/sessions
	setfacl -Rm           m:rwX         var/cache var/logs var/sessions
	setfacl -dRm u:`whoami`:rwX         var/cache var/logs var/sessions
	setfacl -Rm  u:`whoami`:rwX         var/cache var/logs var/sessions
	setfacl -dRm u:${APP_RUNNER_ID}:rwX var/cache var/logs var/sessions
	setfacl -Rm  u:${APP_RUNNER_ID}:rwX var/cache var/logs var/sessions
	setfacl -dRm u:root:rwX             var/cache var/logs var/sessions
	setfacl -Rm  u:root:rwX             var/cache var/logs var/sessions
.PHONY: docker-init
