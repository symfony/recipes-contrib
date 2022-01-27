<?php declare(strict_types=1);

$finder = PhpCsFixer\Finder::create()
    ->in(__DIR__.'/src')
    ->in(__DIR__.'/tests');

$config = new PhpCsFixer\Config();
return $config->setRules([
        '@PSR12' => true,
        'strict_param' => true,
        'array_syntax' => ['syntax' => 'short'],
        '@Symfony' => true,
        '@Symfony:risky' => true,
        'declare_strict_types' => true,
        'no_useless_else' => true,
        'no_useless_return' => true,
        'no_alias_functions' => true,
        'ordered_imports' => true,
        'void_return' => true,
    ])
    ->setRiskyAllowed(true)
    ->setFinder($finder)
    ;
