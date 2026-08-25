<?php

/*
 * Jane OpenAPI generator configuration.
 *
 * - "openapi-file": path to your OpenAPI specification (JSON or YAML).
 *   This file must exist before running bin/jane-open-api-generate:
 *   either place your specification at config/jane/open-api.yaml,
 *   or update this path to point to it.
 * - "namespace": root namespace of the generated code. It must match the
 *   PSR-4 mapping you add to your composer.json autoload section.
 * - "directory": target directory for the generated files.
 *
 * See https://jane.jolicode.com/latest/ for all available options.
 */

return [
    'openapi-file' => __DIR__ . '/open-api.yaml',
    'namespace' => 'MyApp\Library\Generated',
    'directory' => __DIR__ . '/../../generated',
];
