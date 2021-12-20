<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Product\Model\ProductVariantTranslation as BaseProductVariantTranslation;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_variant_translation")
 */
class ProductVariantTranslation extends BaseProductVariantTranslation
{
}
