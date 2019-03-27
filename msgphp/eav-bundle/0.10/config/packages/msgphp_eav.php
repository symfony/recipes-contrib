<?php

use MsgPhp\Eav\Attribute;
use MsgPhp\Eav\AttributeValue;
use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return function (ContainerConfigurator $container) {
    $container->extension('msgphp_eav', [
        'class_mapping' => [
            Attribute::class => \App\Entity\Attribute::class,
            AttributeValue::class => \App\Entity\AttributeValue::class,
        ],
    ]);
};
