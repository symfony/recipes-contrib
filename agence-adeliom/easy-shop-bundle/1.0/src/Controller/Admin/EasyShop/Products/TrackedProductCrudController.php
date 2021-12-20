<?php

namespace App\Controller\Admin\EasyShop\Products;

use App\Entity\EasyShop\Product\ProductVariant;
use Adeliom\EasyShopBundle\Admin\Products\TrackedProductCrudController as BaseTrackedProductCrudController;

class TrackedProductCrudController extends BaseTrackedProductCrudController
{
    public static function getEntityFqcn(): string
    {
        return ProductVariant::class;
    }
}
