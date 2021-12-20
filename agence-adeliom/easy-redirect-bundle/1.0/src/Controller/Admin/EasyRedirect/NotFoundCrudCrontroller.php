<?php

namespace App\Controller\Admin\EasyRedirect;

use Adeliom\EasyRedirectBundle\Admin\NotFoundCrudCrontroller as BaseNotFoundCrudCrontroller;
use App\Entity\EasyRedirect\NotFound;

class NotFoundCrudCrontroller extends BaseNotFoundCrudCrontroller
{
    public static function getEntityFqcn(): string
    {
        return NotFound::class;
    }
}
