<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Product\Model\ProductOption as BaseProductOption;
use Sylius\Component\Product\Model\ProductOptionTranslationInterface;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_option")
 */
class ProductOption extends BaseProductOption
{
    protected function createTranslation(): ProductOptionTranslationInterface
    {
        return new ProductOptionTranslation();
    }

    public static function getTranslationClass(): string
    {
        return ProductOptionTranslation::class;
    }
}
