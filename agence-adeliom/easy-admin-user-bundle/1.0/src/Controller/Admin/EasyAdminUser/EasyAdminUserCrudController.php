<?php

namespace App\Controller\Admin\EasyAdminUser;

use Adeliom\EasyAdminUserBundle\Controller\Admin\EasyAdminUserCrudController as BaseEasyAdminUserCrudController;
use App\Entity\EasyAdmin\User;

class EasyAdminUserCrudController extends BaseEasyAdminUserCrudController
{
    public static function getEntityFqcn(): string
    {
        return User::class;
    }
}
