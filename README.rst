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
the main repository.

Unlike for official recipes, the pull requests for new contrib recipes are
managed by the community. Pull requests are reviewed by the Symfony Bot and
automatically merged when the following conditions are met (in that order):

* The pull request title does not contain "WIP";

* The Symfony Bot approved the pull request and reported no validation errors;

* Someone (not the Symfony bot nor the pull request author) approved the pull
  request;

* The pull request author or the reviewer is a Symfony Core Merger.

.. _`Symfony Flex`: https://github.com/symfony/flex
.. _`Symfony recipes`: https://github.com/symfony/recipes
.. _`documentation`: https://github.com/symfony/recipes

Best practices
--------------

1. A recipe for a bundle should not contain all the default config. A good
recipe only contains suggestion config for an application. That is config that needs
to be configured but no real default value exists.

2. No recipe should modify other bundle's configuration. The only exception is when
a recipe append to a collection.

3. No config should be "copied from package". That makes the recipes impossible
to maintain and to assure their quality.

4. Most Symfony bundles do not need a recipe. A bundle without config or routes
will be installed by Flex with no recipe required.

5. If environment variables are used, they must be provided to the bundle's config.
