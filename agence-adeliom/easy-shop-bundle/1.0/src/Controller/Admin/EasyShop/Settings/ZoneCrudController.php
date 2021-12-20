<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\ZoneCrudController as BaseZoneCrudController;
use App\Entity\EasyShop\Addressing\Zone;

class ZoneCrudController extends BaseZoneCrudController
{
    public static function getEntityFqcn(): string
    {
        return Zone::class;
    }
}
