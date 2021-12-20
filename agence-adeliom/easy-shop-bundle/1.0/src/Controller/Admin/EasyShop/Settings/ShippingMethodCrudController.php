<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\ShippingMethodCrudController as BaseShippingMethodCrudController;
use App\Entity\EasyShop\Shipping\ShippingMethod;

class ShippingMethodCrudController extends BaseShippingMethodCrudController
{
    public static function getEntityFqcn(): string
    {
        return ShippingMethod::class;
    }
}
