<?php

declare(strict_types=1);

namespace App;

use Doctrine\ORM\EntityManagerInterface;
use Wedrix\Watchtower\Executor;

final class WatchtowerExecutor
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly \Psr\Container\ContainerInterface $parameterBag
    ){}

    public function getInstance(): Executor
    {
        return new Executor(
            entityManager: $this->entityManager,
            schemaFileDirectory: dirname(__DIR__) . '/config/graphql/schema.graphql',
            schemaCacheFileDirectory: dirname(__DIR__) . '/var/cache/graphql/schema.graphql',
            cachesTheSchema: $this->parameterBag->get('kernel.environment') !== 'dev',
            pluginsDirectory: dirname(__DIR__) . '/config/graphql/plugins',
            scalarTypeDefinitionsDirectory: dirname(__DIR__) . '/config/graphql/scalar_type_definitions'
        );
    }
}
