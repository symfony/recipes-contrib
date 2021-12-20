<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\ProductTranslation as BaseProductTranslation;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_translation")
 */
class ProductTranslation extends BaseProductTranslation
{
}
