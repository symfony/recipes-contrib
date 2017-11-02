<?php

use App\Entity\Eav\Attribute;
use App\Entity\User\User;
use MsgPhp\Eav\Entity\Attribute as BaseAttribute;
use MsgPhp\Eav\Infra\Doctrine\Type\{AttributeIdType, AttributeValueIdType};
use MsgPhp\User\Entity\User as BaseUser;
use MsgPhp\User\Infra\Doctrine\Type\UserIdType;
use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return function (ContainerConfigurator $container) {
    $container->extension('doctrine', [
        'dbal' => [
            'types' => [
                AttributeIdType::NAME => AttributeIdType::class,
                AttributeValueIdType::NAME => AttributeValueIdType::class,
                UserIdType::NAME => UserIdType::class,
            ],
        ],
        'orm' => [
            'resolve_target_entities' => [
                BaseAttribute::class => Attribute::class,
                BaseUser::class => User::class,
            ],
            'mappings' => [
                'msgphp_attribute' => [
                    'dir' => '%kernel.project_dir%/vendor/msgphp/eav/Infra/Doctrine/Resources/mapping',
                    'type' => 'xml',
                    'prefix' => 'MsgPhp\Eav\Entity',
                    'is_bundle' => false,
                ],
                'msgphp_user' => [
                    'dir' => '%kernel.project_dir%/vendor/msgphp/user/Infra/Doctrine/Resources/mapping',
                    'type' => 'xml',
                    'prefix' => 'MsgPhp\User\Entity',
                    'is_bundle' => false,
                ],
            ],
        ],
    ]);
};
