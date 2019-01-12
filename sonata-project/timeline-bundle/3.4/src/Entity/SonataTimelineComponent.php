<?php

declare(strict_types=1);

namespace App\Entity;

use Sonata\TimelineBundle\Entity\Component as BaseComponent;

/**
 * @ORM\Entity
 * @ORM\Table(name="timeline__component")
 */
class SonataTimelineComponent extends BaseComponent
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
