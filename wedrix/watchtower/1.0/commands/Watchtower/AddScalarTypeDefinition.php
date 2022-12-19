<?php

declare(strict_types=1);

namespace App\Command\Watchtower;

use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\QuestionHelper;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\ConsoleOutputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\HttpKernel\KernelInterface;
use Wedrix\Watchtower\Console;

final class AddScalarTypeDefinition extends Command
{
    protected static $defaultName = 'watchtower:scalar-type-definitions:add';

    protected static $defaultDescription = 'Add a type definition for a custom scalar type.';

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
        
        $typeName = (function () use ($input, $output): bool {
            $helper = $this->getHelper('question');

            if (!$helper instanceof QuestionHelper) {
                throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
            }

            return $helper->ask($input, $output, new Question(
                question: "What is the custom scalar's name? "
            ));
        })();

        $this->watchtowerConsole
            ->addScalarTypeDifinition(
                typeName: $typeName
            );

        return Command::SUCCESS;
    }
}
