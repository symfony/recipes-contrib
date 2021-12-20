<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Shipping;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Shipping\Model\ShippingMethodTranslation as BaseShippingMethodTranslation;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_shipping_method_translation")
 */
class ShippingMethodTranslation extends BaseShippingMethodTranslation
{
}
