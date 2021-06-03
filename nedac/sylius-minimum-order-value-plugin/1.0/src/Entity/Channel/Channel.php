<?php

declare(strict_types=1);

namespace App\Entity\Channel;

use Doctrine\ORM\Mapping as ORM;
use Nedac\SyliusMinimumOrderValuePlugin\Model\ChannelInterface as NedacSyliusMinimumOrderValuePluginChannelInterface;
use Nedac\SyliusMinimumOrderValuePlugin\Model\MinimumOrderValueTrait as
    NedacSyliusMinimumOrderValuePluginMinimumOrderValueTrait;
use Sylius\Component\Core\Model\Channel as BaseChannel;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_channel")
 */
class Channel extends BaseChannel implements NedacSyliusMinimumOrderValuePluginChannelInterface
{
    use NedacSyliusMinimumOrderValuePluginMinimumOrderValueTrait;
}
