<?php

namespace App\Entity\User;

use Doctrine\ORM\Mapping as ORM;
use MsgPhp\User\Entity\UserRole as BaseUserRole;

/**
 * @ORM\Entity()
 *
 * @final
 */
class UserRole extends BaseUserRole
{
}
