<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Currency;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Currency\Model\ExchangeRate as BaseExchangeRate;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_exchange_rate")
 */
class ExchangeRate extends BaseExchangeRate
{
}
