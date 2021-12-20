<?php

namespace App\Controller\Admin\EasyShop\Sales;

use Adeliom\EasyShopBundle\Admin\Sales\PaymentCrudController as BasePaymentCrudController;
use App\Entity\EasyShop\Payment\Payment;

class PaymentCrudController extends BasePaymentCrudController
{
    public static function getEntityFqcn(): string
    {
        return Payment::class;
    }
}
