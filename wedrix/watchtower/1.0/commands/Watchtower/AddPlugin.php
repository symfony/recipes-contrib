<?php

declare(strict_types=1);

namespace App\Command\Watchtower;

use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\QuestionHelper;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\ConsoleOutputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\ChoiceQuestion;
use Symfony\Component\Console\Question\ConfirmationQuestion;
use Symfony\Component\Console\Question\Question;
use Symfony\Component\HttpKernel\KernelInterface;
use Wedrix\Watchtower\Console;

final class AddPlugin extends Command
{
    protected static $defaultName = 'watchtower:plugins:add';

    protected static $defaultDescription = 'Generates a plugin file.';

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
            throw new \LogicException('This command only accepts an instance of "ConsoleOutputInterface".');
        }
        
        $pluginType = (function () use ($input, $output): string {
            $helper = $this->getHelper('question');

            if (!$helper instanceof QuestionHelper) {
                throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
            }

            return $helper->ask($input, $output, new ChoiceQuestion(
                question: "What's the plugin type? ",
                choices: [
                    'filter','ordering','selector','resolver','authorizor','mutation','subscription'
                ],
            ));
        })();

        if ($pluginType === 'filter') {
            $this->watchtowerConsole
                ->addFilterPlugin(
                    parentNodeType: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');

                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }

                        return $helper->ask($input, $output, new Question(
                            question: "What's the parent node type? "
                        ));
                    })(),
                    filterName: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');
        
                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }
            
                        return $helper->ask($input, $output, new Question(
                            question: "What's the filter name? "
                        ));
                    })()
                );
        }

        if ($pluginType === 'ordering') {
            $this->watchtowerConsole
                ->addOrderingPlugin(
                    parentNodeType: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');

                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }

                        return $helper->ask($input, $output, new Question(
                            question: "What's the parent node type? "
                        ));
                    })(),
                    orderingName: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');
        
                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }
            
                        return $helper->ask($input, $output, new Question(
                            question: "What's the ordering name? "
                        ));
                    })()
                );
        }

        if ($pluginType === 'selector') {
            $this->watchtowerConsole
                ->addSelectorPlugin(
                    parentNodeType: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');

                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }

                        return $helper->ask($input, $output, new Question(
                            question: "What's the parent node type? "
                        ));
                    })(),
                    fieldName: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');

                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }

                        return $helper->ask($input, $output, new Question(
                            question: "What's the field name? "
                        ));
                    })()
                );
        }

        if ($pluginType === 'resolver') {
            $this->watchtowerConsole
                ->addResolverPlugin(
                    parentNodeType: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');

                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }

                        return $helper->ask($input, $output, new Question(
                            question: "What's the parent node type? "
                        ));
                    })(),
                    fieldName: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');

                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }

                        return $helper->ask($input, $output, new Question(
                            question: "What's the field name? "
                        ));
                    })()
                );
        }

        if ($pluginType === 'authorizor') {
            $this->watchtowerConsole
                ->addAuthorizorPlugin(
                    nodeType: $nodeType = (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');
        
                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }
            
                        return $helper->ask($input, $output, new Question(
                            question: "What's the node type? "
                        ));
                    })(),
                    isForCollections: (function () use ($input, $output, $nodeType): bool {
                        $helper = $this->getHelper('question');
        
                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }
            
                        return $helper->ask($input, $output, new ConfirmationQuestion(
                            question: "Is the authorizor for collections of $nodeType? "
                        ));
                    })()
                );
        }

        if ($pluginType === 'mutation') {
            $this->watchtowerConsole
                ->addMutationPlugin(
                    mutationName: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');
        
                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }
            
                        return $helper->ask($input, $output, new Question(
                            question: "What's the mutation name? "
                        ));
                    })()
                );
        }

        if ($pluginType === 'subscription') {
            $this->watchtowerConsole
                ->addSubscriptionPlugin(
                    subscriptionName: (function () use ($input, $output): string {
                        $helper = $this->getHelper('question');
        
                        if (!$helper instanceof QuestionHelper) {
                            throw new \Exception("Instance of ".QuestionHelper::class." expected, ".get_class($helper)." given.");
                        }
            
                        return $helper->ask($input, $output, new Question(
                            question: "What's the subscription name? "
                        ));
                    })()
                );
        }

        return Command::SUCCESS;
    }
}