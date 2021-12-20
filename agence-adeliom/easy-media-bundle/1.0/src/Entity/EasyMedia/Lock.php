<?php

namespace App\Entity\EasyMedia;

use Adeliom\EasyMediaBundle\Entity\Lock as BaseLock;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity()
 * @ORM\Table(name="easy_media__lock")
 */
class Lock extends BaseLock
{

}
