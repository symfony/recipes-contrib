<?php
declare(strict_types=1);

require_once __DIR__.'/../vendor/autoload.php';

$config = new \Mukadi\WordpressBundle\Config(
    realpath(__DIR__)
);

// define('WP_ALLOW_MULTISITE', env('WP_ALLOW_MULTISITE', true));

$table_prefix = env('WP_PREFIX', 'wp_');

/* That's all, stop editing! Happy blogging. */
$config->apply();
/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
