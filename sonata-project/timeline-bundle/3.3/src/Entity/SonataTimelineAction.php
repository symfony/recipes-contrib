<?php

declare(strict_types=1);

namespace App\Entity;

use Sonata\TimelineBundle\Entity\Action as BaseAction;

/**
 * @ORM\Entity
 * @ORM\Table(name="timeline__action")
 */
class SonataTimelineAction extends BaseAction
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue(strategy="AUTO")
     *
     * @var int
     */
    protected $id;
}
