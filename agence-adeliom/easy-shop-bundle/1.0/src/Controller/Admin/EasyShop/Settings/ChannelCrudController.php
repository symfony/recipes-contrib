<?php

namespace App\Controller\Admin\EasyShop\Settings;

use Adeliom\EasyShopBundle\Admin\Settings\ChannelCrudController as BaseChannelCrudController;
use App\Entity\EasyShop\Channel\Channel;

class ChannelCrudController extends BaseChannelCrudController
{
    public static function getEntityFqcn(): string
    {
        return Channel::class;
    }
}
