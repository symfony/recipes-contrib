<?php

namespace App\Controller\Admin\EasyShop\Sales;

use Adeliom\EasyShopBundle\Admin\Sales\OrderCrudController as BaseOrderCrudController;
use App\Entity\EasyShop\Order\Order;

class OrderCrudController extends BaseOrderCrudController
{
    public static function getEntityFqcn(): string
    {
        return Order::class;
    }
}
