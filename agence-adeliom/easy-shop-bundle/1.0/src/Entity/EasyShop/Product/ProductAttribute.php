<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Attribute\Model\AttributeTranslationInterface;
use Sylius\Component\Product\Model\ProductAttribute as BaseProductAttribute;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_attribute", indexes={
 *     @ORM\Index(name="sylius_product_attribute_indexes", columns={"storage_type", "type"})
 * })
 */
class ProductAttribute extends BaseProductAttribute
{
    protected function createTranslation(): AttributeTranslationInterface
    {
        return new ProductAttributeTranslation();
    }
}
