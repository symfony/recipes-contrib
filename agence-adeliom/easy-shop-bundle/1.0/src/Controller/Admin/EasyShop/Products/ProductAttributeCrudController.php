<?php

namespace App\Controller\Admin\EasyShop\Products;

use Adeliom\EasyShopBundle\Admin\Products\ProductAttributeCrudController as BaseProductAttributeCrudController;
use App\Entity\EasyShop\Product\ProductAttribute;

class ProductAttributeCrudController extends BaseProductAttributeCrudController
{
    public static function getEntityFqcn(): string
    {
        return ProductAttribute::class;
    }
}
