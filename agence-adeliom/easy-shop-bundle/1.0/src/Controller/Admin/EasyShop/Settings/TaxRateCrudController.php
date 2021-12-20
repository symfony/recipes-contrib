<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\TaxRateCrudController as BaseTaxRateCrudController;
use App\Entity\EasyShop\Taxation\TaxRate;

class TaxRateCrudController extends BaseTaxRateCrudController
{
    public static function getEntityFqcn(): string
    {
        return TaxRate::class;
    }
}
