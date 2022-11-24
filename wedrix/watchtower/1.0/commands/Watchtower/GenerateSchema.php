<?php

declare(strict_types=1);

namespace App\Command\Watchtower;

use App\WatchtowerConsole;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Wedrix\Watchtower\Console;

final class GenerateSchema extends Command
{
    protected static $defaultName = 'watchtower:schema:generate';

    protected static $defaultDescription = 'Generate the schema file.';

    protected readonly Console $watchtowerConsole;

    public function __construct(
        WatchtowerConsole $watchtowerConsole
    )
    {
        $this->watchtowerConsole = $watchtowerConsole->getInstance();

        parent::__construct();
    }

    protected function execute(
        InputInterface $input,
        OutputInterface $output
    ): int
    {
        $output->writeln("<info>Generating Schema ...</info>");

        $this->watchtowerConsole
            ->generateSchema();
        
        $output->writeln("<info>Done!</info>");
            
        return Command::SUCCESS;
    }
}