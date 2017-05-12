Symfony Recipes (Contrib)
=========================

Symfony recipes allow the automation of Composer packages configuration via the
`Symfony Flex`_ Composer plugin.

This repository hosts contributed recipes for Composer packages that are not
part of the "official" `Symfony recipes`_. To enable this repository in your
project, run the following command:

.. code-block:: bash

    composer config extra.symfony.allow-contrib true

For more information about contributing a recipe, read the `documentation`_ on
the main repository.

Unlike for official recipes, the pull requests for new contrib recipes are
managed by the community. Pull requests are reviewed by the Symfony Bot and
automatically merged when the following conditions are met (in that order):

* The pull request title does not contain "WIP";

* The Symfony Bot approved the pull request and reported no validation errors;

* Someone (not the Symfony bot nor the pull request author) approved the pull
  request;

* The pull request author or the reviewer is a "trusted user". A "trusted user"
  being one of the following:

  * A Symfony Core Merger;

  * A user part of a Github team for all modified/deleted/added packages.

.. _`Symfony Flex`: https://github.com/symfony/flex
.. _`Symfony recipes`: https://github.com/symfony/recipes
.. _`documentation`: https://github.com/symfony/recipes
