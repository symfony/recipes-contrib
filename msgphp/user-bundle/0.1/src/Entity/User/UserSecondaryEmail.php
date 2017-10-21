<?php

namespace App\Entity\User;

use Doctrine\ORM\Mapping as ORM;
use MsgPhp\User\Entity\UserSecondaryEmail as BaseUserSecondaryEmail;

/**
 * @ORM\Entity()
 *
 * @final
 */
class UserSecondaryEmail extends BaseUserSecondaryEmail
{
}
