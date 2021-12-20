<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Locale;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Locale\Model\Locale as BaseLocale;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_locale")
 */
class Locale extends BaseLocale
{

}
