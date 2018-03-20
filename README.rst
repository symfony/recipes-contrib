Symfony Recipes (Contrib)
=========================

Symfony recipes allow the automation of Composer packages configuration via the
`Symfony Flex`_ Composer plugin.

This repository hosts contributed recipes for Composer packages that are not
part of the "official" `Symfony recipes`_. To enable recipes defined in this
repository for your project, run the following command:

.. code-block:: bash

    composer config extra.symfony.allow-contrib true

Test it locally
---------------

If Travis CI fails, it could be long to debug what the problem is.
You can reproduce the same things locally.


Here it is the command:

```bash
composer create-project "symfony/skeleton:^4.0" flex
cd flex
composer config extra.symfony.allow-contrib true
export SYMFONY_ENDPOINT=https://symfony.sh/r/github.com/symfony/recipes-contrib/{pull_request}
composer req "my/library-bundle:x.x"
```

Just replace:
- `pull_request`: pull request number
- `my/library-bundle:x.x`: your library with your version

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

* The pull request author or the reviewer is a "trusted user". A "trusted user"
  being one of the following:

  * A Symfony Core Merger;

  * The user is the Github owner for all modified packages;

  * The user is a member of the organizations (publicly visible) for all
    modified packages.

.. _`Symfony Flex`: https://github.com/symfony/flex
.. _`Symfony recipes`: https://github.com/symfony/recipes
.. _`documentation`: https://github.com/symfony/recipes
