<?php

namespace App\Security;

use MsgPhp\User\Entity\User;
use MsgPhp\User\Entity\UserRole;
use MsgPhp\User\Infra\Security\UserRoleProviderInterface;
use MsgPhp\User\Repository\UserRoleRepositoryInterface;

final class UserRoleProvider implements UserRoleProviderInterface
{
    public const ROLE_USER = 'ROLE_USER';
    public const ROLE_DISABLED_USER = 'ROLE_DISABLED_USER';
    public const ROLE_ADMIN = 'ROLE_ADMIN';

    private $repository;

    public function __construct(UserRoleRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function getRoles(User $user): array
    {
        $roles = $user->isEnabled() ? [self::ROLE_USER] : [self::ROLE_DISABLED_USER];

        return array_merge($roles, $this->repository->findAllByUserId($user->getId())->map(function (UserRole $userRole) {
            return $userRole->getRole();
        }));
    }
}
