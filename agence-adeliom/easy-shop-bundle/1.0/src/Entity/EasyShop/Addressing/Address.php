<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Addressing;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\Address as BaseAddress;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_address")
 */
class Address extends BaseAddress
{
}
