<?php

use App\Entity\User\{PendingUser, User, UserAttributeValue, UserRole, UserSecondaryEmail};
use App\Security\UserRoleProvider;
use MsgPhp\User\Infra\Security\UserRoleProviderInterface;
use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return function (ContainerConfigurator $container) {
    $container->extension('msgphp_user', [
        'pending_user_class' => PendingUser::class,
        'user_attribute_value_class' => UserAttributeValue::class,
        'user_class' => User::class,
        'user_role_class' => UserRole::class,
        'user_secondary_email_class' => UserSecondaryEmail::class,
    ]);

    $container->services()
        ->defaults()
            ->autowire()
            ->private()
        ->set(UserRoleProvider::class)
        ->alias(UserRoleProviderInterface::class, UserRoleProvider::class)
    ;
};
