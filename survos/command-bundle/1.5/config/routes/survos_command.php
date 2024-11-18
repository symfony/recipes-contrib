<?php
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

return static function (RoutingConfigurator $routes): void {
    $routes->import('@SurvosCommandBundle/config/routes.php')
        ->prefix('/admin') // consider adding this path to the access_control key in security
    ;
};

