<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\ProductVariant as BaseProductVariant;
use Sylius\Component\Product\Model\ProductVariantTranslationInterface;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_variant")
 */
class ProductVariant extends BaseProductVariant
{
    protected function createTranslation(): ProductVariantTranslationInterface
    {
        return new ProductVariantTranslation();
    }
}
