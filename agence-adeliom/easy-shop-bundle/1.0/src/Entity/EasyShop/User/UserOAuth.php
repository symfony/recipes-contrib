<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\User;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\User\Model\UserOAuth as BaseUserOAuth;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_user_oauth")
 */
class UserOAuth extends BaseUserOAuth
{
}
