<?php

/**
 * This file is used by PHPStan, see https://github.com/phpstan/phpstan-symfony#console-command-analysis.
 */

declare(strict_types=1);

use App\Kernel;
use Symfony\Bundle\FrameworkBundle\Console\Application;
use Symfony\Component\Dotenv\Dotenv;

new Dotenv()->bootEnv(__DIR__ . '/../../.env');

// @phpstan-ignore-next-line argument.type
$kernel = new Kernel($_SERVER['APP_ENV'], (bool) $_SERVER['APP_DEBUG']);

return new Application($kernel);
