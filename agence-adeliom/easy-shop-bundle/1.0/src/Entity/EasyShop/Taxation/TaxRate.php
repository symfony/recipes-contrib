<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Taxation;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\TaxRate as BaseTaxRate;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_tax_rate")
 */
class TaxRate extends BaseTaxRate
{
}
