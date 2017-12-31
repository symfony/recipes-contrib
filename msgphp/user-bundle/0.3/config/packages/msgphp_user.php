<?php

use MsgPhp\User\Entity\{PendingUser, User, UserAttributeValue, UserRole, UserSecondaryEmail};
use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return function (ContainerConfigurator $container) {
    $container->extension('msgphp_user', [
        'class_mapping' => [
            //PendingUser::class => \App\Entity\User\PendingUser::class,
            User::class => \App\Entity\User\User::class,
            //UserAttributeValue::class => \App\Entity\User\UserAttributeValue::class,
            //UserRole::class => \App\Entity\User\UserRole::class,
            //UserSecondaryEmail::class => \App\Entity\User\UserSecondaryEmail::class,
        ],
    ]);
};
