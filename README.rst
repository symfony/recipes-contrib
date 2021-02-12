Symfony Recipes (Contrib)
=========================

Symfony recipes allow the automation of Composer packages configuration via the
`Symfony Flex`_ Composer plugin.

This repository hosts contributed recipes for Composer packages that are not
part of the "official" `Symfony recipes`_. To enable recipes defined in this
repository for your project, run the following command:

.. code-block:: bash

    composer config extra.symfony.allow-contrib true

Contributing
------------

For more information about contributing a recipe, read the `documentation`_ on
the main repository and the Best Practices below.

Unlike for official recipes, the pull requests for new contrib recipes are
managed by the community. Pull requests are reviewed by the Symfony Bot and
automatically merged when the following conditions are met (in that order):

* The pull request title does not contain "WIP";

* The Symfony Bot approved the pull request and reported no validation errors;

* Someone (not the Symfony bot nor the pull request author) approved the pull
  request;

* The pull request author or the reviewer is a Symfony Core Merger.

Best Practices
--------------

Default Bundle Config
#####################

A recipe for a bundle should not contain all the configuration the bundle has to
offer. A good recipe only contains a suggestion config for an application. That
is config that needs to be configured but no real default value exists.

**Example:** The "items per page" in a paginator bundle or API credentials for an API
client bundle.

If environment variables are used, they must be provided to the bundle's config.

A bundle without config or routes do not need a recipe. Flex is smart enough to
install that bundle anyways.

Modify Other Bundle's config
############################

The general rule is that no recipe should modify other bundle's configuration. There
is however one exception. A recipe is allowed to append to a "config collection".

**Example:** Add a new connection to DoctrineBundle or add a new cache adapter to Symfony
Framework bundle.

Maintainability
###############

The symfony/recipes-contrib repository should contain the config for packages. Using
"``copy-from-package`` Configurator" for routes and config is not allowed. That would
make the recipes impossible to maintain and to assure their quality.

Recipes is also not a replacement for ``composer create-project``. That means it is
not intended to be used as "bootstrap full application" and copy a lot of PHP code,
front-end assets etc. Recipes are for quick installation of packages.

.. _`Symfony Flex`: https://github.com/symfony/flex
.. _`Symfony recipes`: https://github.com/symfony/recipes
.. _`documentation`: https://github.com/symfony/recipes
