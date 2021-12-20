<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\TaxCategoryCrudController as BaseTaxCategoryCrudController;
use App\Entity\EasyShop\Taxation\TaxCategory;

class TaxCategoryCrudController extends BaseTaxCategoryCrudController
{
    public static function getEntityFqcn(): string
    {
        return TaxCategory::class;
    }
}
