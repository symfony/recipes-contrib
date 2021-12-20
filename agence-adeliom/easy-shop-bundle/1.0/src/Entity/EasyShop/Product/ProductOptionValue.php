<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Product\Model\ProductOptionValue as BaseProductOptionValue;
use Sylius\Component\Product\Model\ProductOptionValueTranslationInterface;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_option_value")
 */
class ProductOptionValue extends BaseProductOptionValue
{
    protected function createTranslation(): ProductOptionValueTranslationInterface
    {
        return new ProductOptionValueTranslation();
    }
}
