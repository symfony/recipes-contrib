<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Payment;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Payment\Model\PaymentMethodTranslation as BasePaymentMethodTranslation;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_payment_method_translation")
 */
class PaymentMethodTranslation extends BasePaymentMethodTranslation
{
}
