<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Addressing;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Addressing\Model\ZoneMember as BaseZoneMember;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_zone_member")
 */
class ZoneMember extends BaseZoneMember
{
}
