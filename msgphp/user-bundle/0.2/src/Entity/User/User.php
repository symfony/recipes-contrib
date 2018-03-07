<?php

namespace App\Entity\User;

use MsgPhp\User\Entity\User as BaseUser;
use MsgPhp\User\UserIdInterface;

/**
 * @final
 */
class User extends BaseUser
{
    private $id;

    public function __construct(UserIdInterface $id)
    {
        $this->id = $id;
    }

    public function getId(): UserIdInterface
    {
        return $this->id;
    }
}
