<?php

namespace App\Controller\Admin\EasyShop\Customer;

use Adeliom\EasyShopBundle\Admin\Customer\CustomerGroupCrudController as BaseCustomerGroupCrudController;
use App\Entity\EasyShop\Customer\CustomerGroup;

class CustomerGroupCrudController extends BaseCustomerGroupCrudController
{
    public static function getEntityFqcn(): string
    {
        return CustomerGroup::class;
    }
}
