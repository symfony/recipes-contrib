<?php

declare(strict_types=1);

namespace App\Entity;

use Sonata\TimelineBundle\Entity\ActionComponent as BaseActionComponent;

/**
 * @ORM\Entity
 * @ORM\Table(name="timeline__action_component")
 */
class SonataTimelineActionComponent extends BaseActionComponent
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
