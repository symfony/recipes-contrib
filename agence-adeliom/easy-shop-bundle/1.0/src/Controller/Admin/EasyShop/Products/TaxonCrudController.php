<?php

namespace App\Controller\Admin\EasyShop\Products;

use Adeliom\EasyShopBundle\Admin\Products\TaxonCrudController as BaseTaxonCrudController;
use App\Entity\EasyShop\Taxonomy\Taxon;

class TaxonCrudController extends BaseTaxonCrudController
{
    public static function getEntityFqcn(): string
    {
        return Taxon::class;
    }
}
