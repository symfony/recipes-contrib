<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\ShippingCategoryCrudController as BaseShippingCategoryCrudController;
use App\Entity\EasyShop\Shipping\ShippingCategory;

class ShippingCategoryCrudController extends BaseShippingCategoryCrudController
{
    public static function getEntityFqcn(): string
    {
        return ShippingCategory::class;
    }
}
