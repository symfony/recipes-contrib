<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Product\Model\ProductAttributeTranslation as BaseProductAttributeTranslation;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_attribute_translation")
 */
class ProductAttributeTranslation extends BaseProductAttributeTranslation
{
}
