<?php

declare(strict_types=1);

namespace App\Admin;

use App\Entity\User;
use EDB\AdminBundle\Admin\AbstractUserAdmin;

class UserAdmin extends AbstractUserAdmin
{
    public function getEntityClass(): string
    {
        return User::class;
    }
}
