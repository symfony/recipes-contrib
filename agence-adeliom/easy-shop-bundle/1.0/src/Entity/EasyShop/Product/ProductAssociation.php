<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Product\Model\ProductAssociation as BaseProductAssociation;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_association")
 */
class ProductAssociation extends BaseProductAssociation
{
}
