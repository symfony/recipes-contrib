<?php

declare(strict_types=1);

namespace App\Command\Watchtower;

use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\ConsoleOutputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\HttpKernel\KernelInterface;
use Wedrix\Watchtower\Console;

final class ListScalarTypeDefinitions extends Command
{
    protected static $defaultName = 'watchtower:scalar-type-definitions:list';

    protected static $defaultDescription = 'Lists all the project\'s scalar type definitions.';

    protected readonly Console $watchtowerConsole;

    public function __construct(
        EntityManagerInterface $entityManager,
        KernelInterface $kernel
    )
    {
        $this->watchtowerConsole = new Console(
            entityManager: $entityManager,
            schemaFileDirectory: ($projectDir = $kernel->getProjectDir()) . '/config/graphql/schema.graphql',
            schemaCacheFileDirectory: $projectDir . '/var/cache/graphql/schema.graphql',
            pluginsDirectory: $projectDir . '/config/graphql/plugins',
            scalarTypeDefinitionsDirectory: $projectDir . '/config/graphql/scalar_type_definitions'
        );

        parent::__construct();
    }

    protected function execute(
        InputInterface $input,
        OutputInterface $output
    ): int
    {
        if (!$output instanceof ConsoleOutputInterface) {
            throw new \LogicException('This command accepts only an instance of "ConsoleOutputInterface".');
        }

        if (iterator_count($this->watchtowerConsole->scalarTypeDefinitions()) > 0) {
            $styledOutput = new SymfonyStyle($input, $output);
    
            $styledOutput->table(
                ['<comment>Type Name</comment>', '<comment>Directory</comment>'],
                (function (): array {
                    $results = [];
    
                    foreach ($this->watchtowerConsole->scalarTypeDefinitions() as $scalarTypeDefinition) {
                        $results[] = [
                            $scalarTypeDefinition->typeName(),
                            $this->watchtowerConsole->scalarTypeDefinitions()->directory($scalarTypeDefinition)
                        ];
                    }
    
                    return $results;
                })()
            );
        }
        else {
            $output->writeln('<info>You have no scalar type definitions.</info>');
        }

        return Command::SUCCESS;
    }
}
