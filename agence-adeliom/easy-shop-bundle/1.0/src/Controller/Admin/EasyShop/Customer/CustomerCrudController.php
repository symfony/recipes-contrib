<?php

namespace App\Controller\Admin\EasyShop\Customer;

use App\Entity\EasyShop\Customer\Customer;
use Adeliom\EasyShopBundle\Admin\Customer\CustomerCrudController as BaseCustomerCrudController;

class CustomerCrudController extends BaseCustomerCrudController
{
    public static function getEntityFqcn(): string
    {
        return Customer::class;
    }
}
