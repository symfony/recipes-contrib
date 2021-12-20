<?php

namespace App\Entity\EasyRedirect;

use Adeliom\EasyRedirectBundle\Entity\NotFound as BaseNotFound;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity()
 * @ORM\Table(name="easy_redirect__not_found")
 */
class NotFound extends BaseNotFound
{
}
