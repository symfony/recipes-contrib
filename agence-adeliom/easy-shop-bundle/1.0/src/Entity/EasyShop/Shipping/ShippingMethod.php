<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Shipping;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\ShippingMethod as BaseShippingMethod;
use Sylius\Component\Shipping\Model\ShippingMethodTranslationInterface;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_shipping_method")
 */
class ShippingMethod extends BaseShippingMethod
{
    protected function createTranslation(): ShippingMethodTranslationInterface
    {
        return new ShippingMethodTranslation();
    }

    public static function getTranslationClass(): string
    {
        return ShippingMethodTranslation::class;
    }
}
