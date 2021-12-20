<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Product;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\ProductReview as BaseProductReview;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_product_review")
 */
class ProductReview extends BaseProductReview
{
}
