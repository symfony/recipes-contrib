<?php

namespace App\Entity\User;

use Doctrine\ORM\Mapping as ORM;
use MsgPhp\User\Entity\UserAttributeValue as BaseUserAttributeValue;

/**
 * @ORM\Entity()
 *
 * @final
 */
class UserAttributeValue extends BaseUserAttributeValue
{
}
