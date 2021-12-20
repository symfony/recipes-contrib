<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Payment;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Bundle\PayumBundle\Model\GatewayConfig as BaseGatewayConfig;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_gateway_config")
 */
class GatewayConfig extends BaseGatewayConfig
{
}
