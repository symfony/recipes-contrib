<?php
// config/routes.php

use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

return static function (RoutingConfigurator $routes): void {
    $routes->import('@SurvosCommandBundle/config/routes.php')
        ->prefix('/admin') // consider adding this route to the access_control key in security
        ->schemes(['https'])
    ;
};

