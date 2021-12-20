<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Payment;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\PaymentMethod as BasePaymentMethod;
use Sylius\Component\Payment\Model\PaymentMethodTranslationInterface;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_payment_method")
 */
class PaymentMethod extends BasePaymentMethod
{
    protected function createTranslation(): PaymentMethodTranslationInterface
    {
        return new PaymentMethodTranslation();
    }

    public static function getTranslationClass(): string
    {
        return PaymentMethodTranslation::class;
    }
}
