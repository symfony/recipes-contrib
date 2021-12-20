<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Order;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\OrderItemUnit as BaseOrderItemUnit;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_order_item_unit")
 */
class OrderItemUnit extends BaseOrderItemUnit
{
}
