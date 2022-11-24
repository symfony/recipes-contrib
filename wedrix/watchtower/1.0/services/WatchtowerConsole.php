<?php

declare(strict_types=1);

namespace App;

use Doctrine\ORM\EntityManagerInterface;
use Wedrix\Watchtower\Console;

final class WatchtowerConsole
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager
    ){}

    public function getInstance(): Console
    {
        return new Console(
            entityManager: $this->entityManager,
            schemaFileDirectory: dirname(__DIR__) . '/resources/graphql/schema.graphql',
            schemaCacheFileDirectory: dirname(__DIR__) . '/var/cache/graphql/schema.graphql',
            pluginsDirectory: dirname(__DIR__) . '/resources/graphql/plugins',
            scalarTypeDefinitionsDirectory: dirname(__DIR__) . '/resources/graphql/scalar_type_definitions'
        );
    }
}