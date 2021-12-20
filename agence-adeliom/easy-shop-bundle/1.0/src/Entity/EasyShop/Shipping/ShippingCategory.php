<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Shipping;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Shipping\Model\ShippingCategory as BaseShippingCategory;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_shipping_category")
 */
class ShippingCategory extends BaseShippingCategory
{
}
