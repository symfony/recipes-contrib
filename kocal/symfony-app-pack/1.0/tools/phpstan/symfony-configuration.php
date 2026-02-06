<?php

declare(strict_types=1);

require __DIR__ . '/../../vendor/autoload.php';

$env = getenv('APP_ENV') ?: 'test';

$xmlContainerFile = __DIR__ . sprintf('/../../var/cache/%s/App_Kernel%sDebugContainer.xml', $env, ucfirst($env));

if (! file_exists($xmlContainerFile)) {
    throw new RuntimeException(sprintf(<<<ERROR
            PHPStan depends on the meta information the Symfony Dependency Injection that the compiler pass writes.
            The meta xml file could not be found: %s.

            To compile the Symfony container do a cache:clear in the current env (%s) with debug: true!
            ERROR, $xmlContainerFile, $env));
}

return [
    'parameters' => [
        'symfony' => [
            'containerXmlPath' => $xmlContainerFile,
        ],
    ],
];
