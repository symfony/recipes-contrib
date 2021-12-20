<?php

namespace App\Controller\Admin\EasyShop\Products;

use Adeliom\EasyShopBundle\Admin\Products\ProductAssociationTypeCrudController as BaseProductAssociationTypeCrudController;
use App\Entity\EasyShop\Product\ProductAssociationType;

class ProductAssociationTypeCrudController extends BaseProductAssociationTypeCrudController
{
    public static function getEntityFqcn(): string
    {
        return ProductAssociationType::class;
    }
}
