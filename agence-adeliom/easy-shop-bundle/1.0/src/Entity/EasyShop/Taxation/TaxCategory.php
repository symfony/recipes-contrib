<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Taxation;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Taxation\Model\TaxCategory as BaseTaxCategory;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_tax_category")
 */
class TaxCategory extends BaseTaxCategory
{
}
