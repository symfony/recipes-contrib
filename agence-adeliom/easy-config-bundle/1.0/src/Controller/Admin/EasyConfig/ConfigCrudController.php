<?php

namespace App\Controller\Admin\EasyConfig;

use Adeliom\EasyConfigBundle\Controller\Admin\EasyConfigCrudController as BaseConfigCrudController;
use App\Entity\EasyConfig\Config;

class ConfigCrudController extends BaseConfigCrudController
{
    public static function getEntityFqcn(): string
    {
        return Config::class;
    }
}
