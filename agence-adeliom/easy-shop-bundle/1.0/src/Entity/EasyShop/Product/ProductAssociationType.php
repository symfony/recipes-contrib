<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Product\Model\ProductAssociationType as BaseProductAssociationType;
use Sylius\Component\Product\Model\ProductAssociationTypeTranslationInterface;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_association_type")
 */
class ProductAssociationType extends BaseProductAssociationType
{
    protected function createTranslation(): ProductAssociationTypeTranslationInterface
    {
        return new ProductAssociationTypeTranslation();
    }
}
