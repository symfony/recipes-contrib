<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\LocaleCrudController as BaseLocaleCrudController;
use App\Entity\EasyShop\Locale\Locale;

class LocaleCrudController extends BaseLocaleCrudController
{
    public static function getEntityFqcn(): string
    {
        return Locale::class;
    }
}
