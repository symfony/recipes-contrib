<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Currency;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Currency\Model\Currency as BaseCurrency;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_currency")
 */
class Currency extends BaseCurrency
{
}
