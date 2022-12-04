<?php

declare(strict_types=1);

namespace App\Command\Watchtower;

use App\WatchtowerConsole;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\QuestionHelper;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\ConsoleOutputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\Question;
use Wedrix\Watchtower\Console;

final class AddScalarTypeDefinition extends Command
{
    protected static $defaultName = 'watchtower:scalar-type-definitions:add';

    protected static $defaultDescription = 'Add a type definition for a custom scalar type.';

    protected readonly Console $watchtowerConsole;

    public function __construct(
        WatchtowerConsole $watchtowerConsole
    )
    {
        $this->watchtowerConsole = $watchtowerConsole->getInstance();

        parent::__construct();
    }

    protected function configure()
    {
        $this->addOption(
                'type-name', 
                null,
                InputOption::VALUE_REQUIRED, 
                "The custom scalar's name."
            );
    }

    protected function execute(
        InputInterface $input,
        OutputInterface $output
    ): int
    {
        if (!$output instanceof ConsoleOutputInterface) {
            throw new \LogicException('This command accepts only an instance of "ConsoleOutputInterface".');
        }

        if (is_null($typeName = $input->getOption('type-name'))) {
            $typeName = (function () use ($input, $output): bool {
                $helper = $this->getHelper('question');

                if (!$helper instanceof QuestionHelper) {
                    throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                }
    
                return $helper->ask($input, $output, new Question(
                    question: "What is the custom scalar's name? "
                ));
            })();
        }

        $this->watchtowerConsole
            ->addScalarTypeDifinition(
                typeName: $typeName
            );

        return Command::SUCCESS;
    }
}
