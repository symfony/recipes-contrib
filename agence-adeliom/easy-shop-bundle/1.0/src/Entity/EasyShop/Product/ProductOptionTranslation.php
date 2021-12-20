<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Product\Model\ProductOptionTranslation as BaseProductOptionTranslation;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_option_translation")
 */
class ProductOptionTranslation extends BaseProductOptionTranslation
{
}
