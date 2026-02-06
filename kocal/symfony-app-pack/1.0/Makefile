ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
include $(ROOT_DIR)/tools/make/text.mk
include $(ROOT_DIR)/tools/make/help.mk
include $(ROOT_DIR)/tools/make/os.mk
include $(ROOT_DIR)/tools/make/git.mk

.DEFAULT_GOAL := help

# Executables
SF := symfony
SF_PROXY = $(shell $(SF) local:proxy:url)
SF_CONSOLE := $(SF) console
PHP := $(SF) php
COMPOSER := $(SF) composer

UID := $(shell id -u)
GID := $(shell id -g)
DC := USER_ID=$(UID) GROUP_ID=$(GID) docker compose --env-file /dev/null

## Install everything needed to start the project
install:
	$(SF) local:server:ca:install
	$(MAKE) start
	$(MAKE) app.install

## Start the environment
start:
	$(DC) up -d
	$(SF) proxy:start
	$(SF) serve

## Stop the environment
stop:
	$(DC) kill

## Stop and delete the environment and project data (database, logs, etc.)
delete:
	$(DC) down -v --remove-orphans

## App - Install the application
app.install:
	@$(call action, Installing PHP dependencies...)
	$(COMPOSER) install --prefer-dist

	@$(call action, Running DB migrations...)
	$(SF_CONSOLE) doctrine:migrations:migrate --no-interaction --all-or-nothing

## App - Install the application (alias to "make app.install")
app.update: app.install

######
# QA #
######

## QA - Run all QA checks
qa: archi refactor cs lint phpstan test

## QA - Run all QA checks and fix issues
qa.fix: archi refactor.fix cs.fix lint.fix phpstan test

#########
# Archi #
#########

## Architecture - Run architecture checks
archi: archi.back

## Architecture - Run architecture checks for backend
archi.back:
	$(PHP) vendor/bin/deptrac --report-uncovered --fail-on-uncovered

############
# Refactor #
############

## Refactor - Run all refactor checks
refactor: refactor.back

## Refactor - Run all refactor checks and fix issues
refactor.fix: refactor.back.fix

## Refactor - Run refactor checks for backend
refactor.back:
	$(PHP) vendor/bin/rector process --dry-run

## Refactor - Run refactor checks for backend and fix issues
refactor.back.fix:
	$(PHP) vendor/bin/rector process

################
# Coding style #
################

## Coding style - Run all coding style checks
cs: cs.back cs.front

## Coding style - Run all coding style checks and fix issues
cs.fix: cs.back.fix cs.front.fix

## Coding style - Check backend coding style
cs.back:
	$(PHP) vendor/bin/ecs check
	$(PHP) vendor/bin/twig-cs-fixer

## Coding style - Check backend coding style and fix issues
cs.back.fix:
	$(PHP) vendor/bin/ecs check --fix
	$(PHP) vendor/bin/twig-cs-fixer --fix

## Coding style - Check frontend coding style
cs.front: bin/oxfmt
	bin/oxfmt --check

## Coding style - Check frontend coding style and fix issues
cs.front.fix: bin/oxfmt
	bin/oxfmt

bin/oxfmt:
	@$(call action, Downloading oxfmt...)
	$(SF_CONSOLE) oxc:download:oxfmt
	@$(call success, oxfmt downloaded successfully)

##########
# Linter #
##########

## Linter - Run all linters
lint: lint.back lint.front

## Linter - Run all linters and fix issues
lint.fix: lint.back lint.front.fix

## Linter - Run linters for backend
lint.back:
	$(SF_CONSOLE) lint:container
	$(SF_CONSOLE) lint:xliff translations
	$(SF_CONSOLE) lint:yaml --parse-tags config
	$(SF_CONSOLE) lint:twig templates
	#$(SF_CONSOLE) doctrine:schema:validate

## Linter - Lint front files
lint.front: bin/oxlint
	bin/oxlint

## Linter - Lint front files and fix issues
lint.front.fix: bin/oxlint
	bin/oxlint --fix

bin/oxlint:
	@$(call action, Downloading oxlint...)
	$(SF_CONSOLE) oxc:download:oxlint

###########
# PHPStan #
###########

## PHPStan - Run PHPStan
phpstan:
	$(PHP) vendor/bin/phpstan analyse

## PHPStan - Run PHPStan and update the baseline
phpstan.generate-baseline:
	$(PHP) vendor/bin/phpstan analyse --generate-baseline

#########
# Tests #
#########

## Tests - Run all tests
test: test.back

## Tests - Run backend tests
test.back:
	$(PHP) vendor/bin/phpunit
## Tests - Run backend tests with coverage

test.back.coverage:
	$(PHP) vendor/bin/phpunit --coverage-html .cache/phpunit/coverage-html

-include $(ROOT_DIR)/Makefile.local
