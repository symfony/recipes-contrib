<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Sonata\NotificationBundle\Entity\BaseMessage as BaseMessage;

/**
 * @ORM\Entity
 * @ORM\Table(name="notification__message")
 */
class SonataNotificationMessage extends BaseMessage
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * Get id.
     *
     * @return int $id
     */
    public function getId()
    {
        return $this->id;
    }
}
