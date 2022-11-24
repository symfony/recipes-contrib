<?php

declare(strict_types=1);

namespace App\Command\Watchtower;

use App\WatchtowerConsole;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\TableSeparator;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\ConsoleOutputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Wedrix\Watchtower\Console;

final class ListPlugins extends Command
{
    protected static $defaultName = 'watchtower:plugins:list';

    protected static $defaultDescription = 'Lists all the project\'s plugins.';

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
        if (!$output instanceof ConsoleOutputInterface) {
            throw new \LogicException('This command accepts only an instance of "ConsoleOutputInterface".');
        }

        if (iterator_count($this->watchtowerConsole->plugins()) > 0) {
            $styledOutput = new SymfonyStyle($input, $output);
    
            $styledOutput->table(
                ['<comment>Type</comment>', '<comment>Name</comment>'],
                (function (): array {
                    $results = [];
                    $parsedPluginTypes = [];
    
                    foreach ($this->watchtowerConsole->plugins() as $plugin) {
                        if (!in_array($plugin->type(), $parsedPluginTypes) && !empty($parsedPluginTypes)) {
                            $results[] = new TableSeparator();
                        }
    
                        $results[] = [
                            in_array($plugin->type(), $parsedPluginTypes)
                            ? '' 
                            : '<info>'.$plugin->type().'</info>',
                            $plugin->name()
                        ];
    
                        if (!in_array($plugin->type(), $parsedPluginTypes)) {
                            $parsedPluginTypes[] = $plugin->type();
                        }
                    }
    
                    return $results;
                })()
            );
        }
        else {
            $output->writeln('<info>You have no plugins.</info>');
        }

        return Command::SUCCESS;
    }
}
