<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Payment;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Bundle\PayumBundle\Model\PaymentSecurityToken as BasePaymentSecurityToken;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_payment_security_token")
 */
class PaymentSecurityToken extends BasePaymentSecurityToken
{
}
