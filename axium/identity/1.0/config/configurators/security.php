<?php

namespace Axium\Identity\Recipe;

use Symfony\Component\Yaml\Yaml;

class SecurityConfigurator
{
    public function configure(array $options): void
    {
        $file = 'config/packages/security.yaml';

        if (!file_exists($file)) {
            return;
        }

        $config = Yaml::parseFile($file);

        $security = $config['security'] ?? [];

        // Ajouter le provider
        $security['providers']['axium_identity'] = [
            'id' => 'Axium\\Identity\\Security\\IdentityUserProvider'
        ];

        // Ajouter firewall
        $security['firewalls']['main']['custom_authenticator'][] =
            'Axium\\Identity\\Security\\IdentityAuthenticator';

        // Ajouter access_control
        $security['access_control'][] = [
            'path' => '^/api/oauth/token',
            'roles' => 'PUBLIC_ACCESS'
        ];

        $config['security'] = $security;

        file_put_contents(
            $file,
            Yaml::dump($config, 10)
        );
    }
}