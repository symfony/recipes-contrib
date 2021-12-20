<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Product\Model\ProductAssociationTypeTranslation as BaseProductAssociationTypeTranslation;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_association_type_translation")
 */
class ProductAssociationTypeTranslation extends BaseProductAssociationTypeTranslation
{
}
