<?php

use TwigCsFixer\Config\Config;
use TwigCsFixer\Ruleset\Ruleset;

$ruleset = new Ruleset();
$ruleset->addStandard(new \TwigCsFixer\Standard\TwigCsFixer());

$config = new Config();
$config->setRuleset($ruleset);

return $config;
