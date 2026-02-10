<?php

/**
 * This file is used by PHPStan, see https://github.com/phpstan/phpstan-symfony#console-command-analysis.
 */

declare(strict_types=1);

use App\Kernel;
use Doctrine\ORM\EntityManager;
use Symfony\Component\Dotenv\Dotenv;

new Dotenv()->bootEnv(__DIR__ . '/../../.env');

// @phpstan-ignore-next-line argument.type
$kernel = new Kernel($_SERVER['APP_ENV'], (bool) $_SERVER['APP_DEBUG']);
$kernel->boot();

/** @var EntityManager $entityManager */
$entityManager = $kernel->getContainer()->get('doctrine')->getManager();

return $entityManager;
