<?php

namespace App\Controller\Admin\EasyShop\Sales;

use Adeliom\EasyShopBundle\Admin\Sales\ShipmentCrudController as BaseShipmentCrudController;
use App\Entity\EasyShop\Shipping\Shipment;

class ShipmentCrudController extends BaseShipmentCrudController
{
    public static function getEntityFqcn(): string
    {
        return Shipment::class;
    }
}
