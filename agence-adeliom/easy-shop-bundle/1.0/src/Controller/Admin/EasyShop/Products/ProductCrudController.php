<?php

namespace App\Controller\Admin\EasyShop\Products;

use Adeliom\EasyShopBundle\Admin\Products\ProductCrudController as BaseProductCrudController;
use App\Entity\EasyShop\Product\Product;

class ProductCrudController extends BaseProductCrudController
{
    public static function getEntityFqcn(): string
    {
        return Product::class;
    }
}
