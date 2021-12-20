<?php

namespace App\Controller\Admin\EasyShop\Products;

use Adeliom\EasyShopBundle\Admin\Products\ProductOptionCrudController as BaseProductOptionCrudController;
use App\Entity\EasyShop\Product\ProductOption;

class ProductOptionCrudController extends BaseProductOptionCrudController
{
    public static function getEntityFqcn(): string
    {
        return ProductOption::class;
    }
}
