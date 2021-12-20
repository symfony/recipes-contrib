<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Customer;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Customer\Model\CustomerGroup as BaseCustomerGroup;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_customer_group")
 */
class CustomerGroup extends BaseCustomerGroup
{
}
