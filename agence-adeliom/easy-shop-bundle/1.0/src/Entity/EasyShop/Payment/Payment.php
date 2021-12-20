<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Payment;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\Payment as BasePayment;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_payment")
 */
class Payment extends BasePayment
{
}
