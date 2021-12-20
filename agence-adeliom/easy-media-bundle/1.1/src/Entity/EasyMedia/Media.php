<?php

namespace App\Entity\EasyMedia;

use Adeliom\EasyMediaBundle\Entity\Media as BaseMedia;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity()
 * @ORM\Table(name="easy_media__media")
 */
class Media extends BaseMedia
{

}
