<?php

namespace App\Entity\EasyConfig;

use Adeliom\EasyConfigBundle\Entity\Config as BaseConfig;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="App\Repository\EasyConfig\ConfigRepository")
 * @ORM\Table(name="easy_config__config")
 */
class Config extends BaseConfig
{

}
