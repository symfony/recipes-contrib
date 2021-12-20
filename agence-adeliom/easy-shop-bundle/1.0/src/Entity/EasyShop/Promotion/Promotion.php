<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Promotion;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\Promotion as BasePromotion;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_promotion")
 */
class Promotion extends BasePromotion
{
}
