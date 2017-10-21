<?php

namespace App\Entity\User;

use Doctrine\ORM\Mapping as ORM;
use MsgPhp\User\Entity\User as BaseUser;

/**
 * @ORM\Entity()
 *
 * @final
 */
class User extends BaseUser
{
}
