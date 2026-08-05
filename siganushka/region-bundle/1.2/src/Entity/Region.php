<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Siganushka\RegionBundle\Entity\Region as BaseRegion;

#[ORM\Entity]
class Region extends BaseRegion
{
}
