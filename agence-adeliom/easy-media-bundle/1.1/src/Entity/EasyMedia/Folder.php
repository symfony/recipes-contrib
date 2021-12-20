<?php

namespace App\Entity\EasyMedia;

use Adeliom\EasyMediaBundle\Entity\Folder as BaseFolder;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity()
 * @ORM\Table(name="easy_media__folder")
 */
class Folder extends BaseFolder
{

}
