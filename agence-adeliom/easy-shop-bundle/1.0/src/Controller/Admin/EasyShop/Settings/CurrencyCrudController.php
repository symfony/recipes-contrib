<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\CurrencyCrudController as BaseCurrencyCrudController;
use App\Entity\EasyShop\Currency\Currency;

class CurrencyCrudController extends BaseCurrencyCrudController
{
    public static function getEntityFqcn(): string
    {
        return Currency::class;
    }
}
