<?php

declare(strict_types=1);

namespace App\Command\Watchtower;

use App\WatchtowerConsole;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\ConsoleOutputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ChoiceQuestion;
use Symfony\Component\Console\Question\ConfirmationQuestion;
use Symfony\Component\Console\Question\Question;
use Wedrix\Watchtower\Console;

final class AddPlugin extends Command
{
    protected static $defaultName = 'watchtower:plugins:add';

    protected static $defaultDescription = 'Generates a plugin file.';

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
                'type', 
                't',
                InputOption::VALUE_REQUIRED, 
                "The plugin type. Either filter,ordering,selector,resolver,authorizor,mutation, or subscription."
            )->addOption(
                'node-type', 
                null,
                InputOption::VALUE_REQUIRED, 
                "The node type param for filter,ordering,selector,resolver, and authorizor plugin types."
            )->addOption(
                'field-name', 
                null,
                InputOption::VALUE_REQUIRED, 
                "The field name param for selector,resolver,authorizor,mutation, and subscription plugin types."
            )->addOption(
                'filter', 
                null,
                InputOption::VALUE_REQUIRED, 
                "The filter param for the filter plugin type."
            )->addOption(
                'ordering', 
                null,
                InputOption::VALUE_REQUIRED, 
                "The ordering param for the ordering plugin type."
            )->addOption(
                'is-for-collections', 
                null,
                InputOption::VALUE_REQUIRED, 
                "The param for the authorizor plugin type that indacates whether it applies to collections or single results."
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

        if (
            !in_array($pluginType = $input->getOption('type'), $pluginTypes = [
                    'filter','ordering','selector','resolver','authorizor','mutation','subscription'
                ]
            )
        ) {
            $pluginType = (function () use ($input, $output, $pluginTypes): string {
                $helper = $this->getHelper('question');
    
                return $helper->ask($input, $output, new ChoiceQuestion(
                    question: "What's the plugin type? ",
                    choices: $pluginTypes,
                ));
            })();
        }

        if (
            in_array($pluginType, $pluginTypes = [
                    'filter','ordering','selector','resolver','authorizor'
                ]
            )
            &&
            is_null($nodeType = $input->getOption('node-type'))
        ) {
            $nodeType = (function () use ($input, $output): string {
                $helper = $this->getHelper('question');
    
                return $helper->ask($input, $output, new Question(
                    question: "What's the node type? "
                ));
            })();
        }

        if (
            in_array($pluginType, $pluginTypes = [
                    'selector','resolver','authorizor','mutation','subscription'
                ]
            )
            &&
            is_null($fieldName = $input->getOption('field-name'))
        ) {
            $fieldName = (function () use ($input, $output): string {
                $helper = $this->getHelper('question');
    
                return $helper->ask($input, $output, new Question(
                    question: "What's the field name? "
                ));
            })();
        }

        if (
            ($pluginType === 'filter') 
            && 
            is_null($filter = $input->getOption('filter'))
        ) {
            $filter = (function () use ($input, $output): string {
                $helper = $this->getHelper('question');
    
                return $helper->ask($input, $output, new Question(
                    question: "What's the filter? "
                ));
            })();
        }

        if (
            ($pluginType === 'ordering') 
            && 
            is_null($filter = $input->getOption('ordering'))
        ) {
            $ordering = (function () use ($input, $output): string {
                $helper = $this->getHelper('question');
    
                return $helper->ask($input, $output, new Question(
                    question: "What's the ordering? "
                ));
            })();
        }

        if ($pluginType === 'authorizor') {
            if (is_null($isForCollections = $input->getOption('is-for-collections'))) {
                $isForCollections = (function () use ($input, $output): bool {
                    $helper = $this->getHelper('question');
        
                    return $helper->ask($input, $output, new ConfirmationQuestion(
                        question: "Is the authorizor for collections? "
                    ));
                })();
            }
            else {
                $isForCollections = (bool) preg_match('/^y/i', $isForCollections);
            }
        }

        if ($pluginType === 'filter') {
            $this->watchtowerConsole
                ->addFilterPlugin(
                    nodeType: $nodeType,
                    filter: $filter
                );
        }

        if ($pluginType === 'ordering') {
            $this->watchtowerConsole
                ->addOrderingPlugin(
                    nodeType: $nodeType,
                    ordering: $ordering
                );
        }

        if ($pluginType === 'selector') {
            $this->watchtowerConsole
                ->addSelectorPlugin(
                    nodeType: $nodeType,
                    fieldName: $fieldName
                );
        }

        if ($pluginType === 'resolver') {
            $this->watchtowerConsole
                ->addResolverPlugin(
                    nodeType: $nodeType,
                    fieldName: $fieldName
                );
        }

        if ($pluginType === 'authorizor') {
            $this->watchtowerConsole
                ->addAuthorizorPlugin(
                    nodeType: $nodeType,
                    isForCollections: $isForCollections
                );
        }

        if ($pluginType === 'mutation') {
            $this->watchtowerConsole
                ->addMutationPlugin(
                    fieldName: $fieldName
                );
        }

        if ($pluginType === 'subscription') {
            $this->watchtowerConsole
                ->addSubscriptionPlugin(
                    fieldName: $fieldName
                );
        }

        return Command::SUCCESS;
    }
}