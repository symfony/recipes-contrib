<?php

use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return static function (ContainerConfigurator $container): void {
    $container->extension('survos_command', [
        'namespaces' => ['app', 'survos']
    ]);
};
//survos_command:
//namespaces: [app, project, survos]
