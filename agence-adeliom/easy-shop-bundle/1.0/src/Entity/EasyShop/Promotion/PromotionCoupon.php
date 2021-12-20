<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Promotion;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\PromotionCoupon as BasePromotionCoupon;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_promotion_coupon")
 */
class PromotionCoupon extends BasePromotionCoupon
{
}
