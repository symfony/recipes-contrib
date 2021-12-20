<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\CountryCrudController as BaseCountryCrudController;
use App\Entity\EasyShop\Addressing\Country;

class CountryCrudController extends BaseCountryCrudController
{
    public static function getEntityFqcn(): string
    {
        return Country::class;
    }
}
