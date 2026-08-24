<?php

/*
 * Jane JSON Schema generator configuration.
 *
 * - "json-schema-file": path to your JSON Schema specification.
 *   This file must exist before running bin/jane-json-schema-generate:
 *   either place your specification at config/jane/json-schema.json,
 *   or update this path to point to it.
 * - "root-class": name of the root class generated from your schema.
 * - "namespace": root namespace of the generated code. It must match the
 *   PSR-4 mapping you add to your composer.json autoload section.
 * - "directory": target directory for the generated files.
 *
 * See https://jane.jolicode.com/latest/ for all available options.
 */

return [
    'json-schema-file' => __DIR__ . '/json-schema.json',
    'root-class' => 'MyModel',
    'namespace' => 'MyApp\Library\Generated',
    'directory' => __DIR__ . '/../../generated',
];
