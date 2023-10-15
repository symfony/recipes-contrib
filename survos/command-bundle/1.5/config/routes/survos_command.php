<?php

// config/routes.php
use Survos\CommandBundle\Controller\CommandController;
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

return function (RoutingConfigurator $routes) {
    $routes->add('survos_commands', '/admin/commands')
        ->controller([CommandController::class, 'commands'])
    ;

    $routes->add('survos_command', 'admin/run-command/{commandName}')
        ->controller([CommandController::class, 'runCommand'])
    ;

};
