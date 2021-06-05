<?php

use App\Kernel;
use Symfony\Component\Debug\Debug;
use Symfony\Component\Dotenv\Dotenv;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\DependencyInjection\ContainerInterface;

require __DIR__.'/../vendor/autoload.php';

function run(){
    // The check is to ensure we don't use .env in production
    if (!isset($_SERVER['APP_ENV'])) {
        if (!class_exists(Dotenv::class)) {
            throw new \RuntimeException('APP_ENV environment variable is not defined. You need to define environment variables for configuration or add "symfony/dotenv" as a Composer dependency to load variables from a .env file.');
        }
        (new Dotenv())->load(__DIR__.'/../.env');
    }

    $env = $_SERVER['APP_ENV'] ?? 'dev';
    $debug = (bool) ($_SERVER['APP_DEBUG'] ?? ('prod' !== $env));

    if ($debug) {
        umask(0000);

        Debug::enable();
    }
    define('WP_DEBUG', $debug);

    if ($trustedProxies = $_SERVER['TRUSTED_PROXIES'] ?? false) {
        Request::setTrustedProxies(explode(',', $trustedProxies), Request::HEADER_X_FORWARDED_ALL ^ Request::HEADER_X_FORWARDED_HOST);
    }

    if ($trustedHosts = $_SERVER['TRUSTED_HOSTS'] ?? false) {
        Request::setTrustedHosts(explode(',', $trustedHosts));
    }

    $kernel = new Kernel($env, $debug);
    # SF container in WP
    $GLOBALS['sf'] = function ($id) use (&$kernel) {
        return $kernel->getContainer()->get($id);
    };

    $kernelRequest = Request::createFromGlobals();
    $kernelResponse = $kernel->handle($kernelRequest);
    $kernelResponse->send();
    $kernel->terminate($kernelRequest, $kernelResponse);
}
run();
