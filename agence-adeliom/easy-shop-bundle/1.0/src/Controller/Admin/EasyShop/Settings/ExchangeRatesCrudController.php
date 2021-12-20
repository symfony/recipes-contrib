<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\ExchangeRatesCrudController as BaseExchangeRatesCrudController;
use App\Entity\EasyShop\Currency\ExchangeRate;

class ExchangeRatesCrudController extends BaseExchangeRatesCrudController
{
    public static function getEntityFqcn(): string
    {
        return ExchangeRate::class;
    }
}
