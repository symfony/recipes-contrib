<?php

namespace App\Entity\User;

use Doctrine\ORM\Mapping as ORM;
use MsgPhp\User\Entity\PendingUser as BasePendingUser;

/**
 * @ORM\Entity()
 *
 * @final
 */
class PendingUser extends BasePendingUser
{
}
