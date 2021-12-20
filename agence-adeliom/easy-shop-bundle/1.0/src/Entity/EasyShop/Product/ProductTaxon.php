<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\ProductTaxon as BaseProductTaxon;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_taxon")
 */
class ProductTaxon extends BaseProductTaxon
{
}
