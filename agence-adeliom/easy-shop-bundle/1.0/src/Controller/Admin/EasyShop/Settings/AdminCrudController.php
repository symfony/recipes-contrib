<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\AdminCrudController as BaseAdminCrudController;
use App\Entity\EasyShop\User\AdminUser;

class AdminCrudController extends BaseAdminCrudController
{
    public static function getEntityFqcn(): string
    {
        return AdminUser::class;
    }
}
