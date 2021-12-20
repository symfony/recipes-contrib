<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Promotion;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Promotion\Model\PromotionAction as BasePromotionAction;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_promotion_action")
 */
class PromotionAction extends BasePromotionAction
{
}
