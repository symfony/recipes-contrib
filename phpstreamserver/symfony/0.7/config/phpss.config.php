<?php

use PHPStreamServer\Core\ReloadStrategy\ExceptionReloadStrategy;
use PHPStreamServer\Core\Server;
use PHPStreamServer\Symfony\Worker\SymfonyHttpServerProcess;

return static function (Server $server): void {
    $server->addWorker(new SymfonyHttpServerProcess(
        listen: '0.0.0.0:8080',
        reloadStrategies: [
            new ExceptionReloadStrategy(),
        ],
    ));
};
