<?php

declare(strict_types=1);

namespace App\Command\Watchtower;

use App\WatchtowerConsole;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Wedrix\Watchtower\Console;

final class UpdateSchema extends Command
{
    protected static $defaultName = 'watchtower:schema:update';

    protected static $defaultDescription = 'Update queries in the schema file to match the project\'s Doctrine models.';

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
        $this->watchtowerConsole
            ->updateSchema();
            
        return Command::SUCCESS;
    }
}