<?php

declare(strict_types=1);

namespace App\Entity;

use Sonata\TimelineBundle\Entity\Timeline as BaseTimeline;

/**
 * @ORM\Entity
 * @ORM\Table(name="timeline__timeline")
 */
class SonataTimeline extends BaseTimeline
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
