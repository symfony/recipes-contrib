<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\User;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\ShopUser as BaseShopUser;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_shop_user")
 */
class ShopUser extends BaseShopUser
{
}
