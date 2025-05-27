<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Sonata\PageBundle\Entity\BaseSite;

#[ORM\Entity]
#[ORM\Table(name: 'page__site')]
class SonataPageSite extends BaseSite
{
    #[ORM\Id]
    #[ORM\Column(type: Types::INTEGER)]
    #[ORM\GeneratedValue]
    protected $id;
}
