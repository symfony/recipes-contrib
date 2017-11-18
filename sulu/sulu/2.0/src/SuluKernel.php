<?php

namespace App;

use Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait;
use Symfony\Component\Config\Loader\LoaderInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\Routing\RouteCollectionBuilder;

class SuluKernel extends Kernel
{
    /**
     * @var string
     */
    private $context;

    /**
     * @var array
     */
    private $configuration;

    public function __construct(string $environment, $debug)
    {
        parent::__construct($environment, $debug);

        $this->context = $this->detectContext();

        $configurations = require dirname(__DIR__) . '/config/contexts.php';
        $this->configuration = $configurations[$this->context];
    }

    private function detectContext()
    {
        if (!$_SERVER || !array_key_exists('REQUEST_URI', $_SERVER)) {
            return getenv('APP_CONTEXT') ?: 'admin';
        }

        return preg_match('/^\/admin(\/|$)/', $_SERVER['REQUEST_URI']) ? 'admin' : 'website';
    }

    public function getCacheDir()
    {
        return $this->getProjectDir() . '/var/cache/' . $this->context . '/' . $this->environment;
    }

    public function getLogDir()
    {
        return $this->getProjectDir() . '/var/log/' . $this->context;
    }

    public function registerBundles()
    {
        $contents = require $this->getProjectDir().'/config/bundles.php';
        foreach ($contents as $class => $envs) {
            if (in_array($class, $this->configuration['excluded_bundles'])) {
                continue;
            }

            if (isset($envs['all']) || isset($envs[$this->environment])) {
                yield new $class();
            }
        }
    }

    protected function configureContainer(ContainerBuilder $container, LoaderInterface $loader)
    {
        $container->setParameter('container.autowiring.strict_mode', true);
        $container->setParameter('container.dumper.inline_class_loader', true);
        $confDir = $this->getProjectDir().'/config';
        $loader->load($confDir.'/packages/*'.self::CONFIG_EXTS, 'glob');
        if (is_dir($confDir.'/packages/'.$this->environment)) {
            $loader->load($confDir.'/packages/'.$this->environment.'/**/*'.self::CONFIG_EXTS, 'glob');
        }
        if (is_dir($confDir . '/packages/' . $this->context)) {
            $loader->load($confDir . '/packages/' . $this->context . '/**/*' . self::CONFIG_EXTS, 'glob');
        }
        $loader->load($confDir.'/services'.self::CONFIG_EXTS, 'glob');
        $loader->load($confDir.'/services_'.$this->environment.self::CONFIG_EXTS, 'glob');
    }

    protected function configureRoutes(RouteCollectionBuilder $routes)
    {
        $confDir = $this->getProjectDir().'/config';
        if (is_dir($confDir.'/routes/')) {
            $routes->import($confDir.'/routes/*'.self::CONFIG_EXTS, '/', 'glob');
        }
        if (is_dir($confDir.'/routes/'.$this->environment)) {
            $routes->import($confDir.'/routes/'.$this->environment.'/**/*'.self::CONFIG_EXTS, '/', 'glob');
        }
        if (is_dir($confDir . '/routes/' . $this->context)) {
            $routes->import($confDir . '/routes/' . $this->context . '/**/*' . self::CONFIG_EXTS, '/', 'glob');
        }
        $routes->import($confDir.'/routes'.self::CONFIG_EXTS, '/', 'glob');
    }

    protected function getKernelParameters()
    {
        return array_merge(
            parent::getKernelParameters(),
            [
                'sulu.context' => $this->context,
                'sulu.cache_dir' => $this->getCacheDir().'/sulu',
                'kernel.public_dir' => $this->getProjectDir().'/public',
            ]
        );
    }

    public function getName()
    {
        return $this->context;
    }
}
