<?php

/*
 * This is the project's atoum configuration file.
 * You can find more information about atoum configuration at:
 * https://github.com/atoum/atoum
 */

use atoum\atoum;

$script->addDefaultArguments(
    // Enable code coverage (optional, comment out if you don't need it)
    // '--enable-branch-and-path-coverage',
    
    // Test directories (adjust as needed)
    '--directories', 'tests/Units',
    
    // Use the Symfony container for dependency injection
    '--bootstrap-file', 'vendor/autoload.php'
);

// Configure test runner
$runner->addTestsFromDirectory(__DIR__ . '/tests/Units');

// CLI Report
$cliReport = $script->addDefaultReport();

// Code coverage report (HTML)
if (getenv('GENERATE_COVERAGE') === 'true') {
    $coverageField = new atoum\report\fields\runner\coverage\html(
        'atoum', 
        __DIR__ . '/var/coverage'
    );
    $coverageReport = new atoum\reports\coverage\html();
    $coverageReport->addField($coverageField);
    $runner->addReport($coverageReport);
}
