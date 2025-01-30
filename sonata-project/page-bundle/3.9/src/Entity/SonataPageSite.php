<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use JMS\Serializer\Annotation as Serializer;
use Sonata\PageBundle\Entity\BaseSite;

/**
 * @ORM\Entity
 * @ORM\Table(name="page__site")
 * @ORM\HasLifecycleCallbacks
 */
class SonataPageSite extends BaseSite
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue(strategy="AUTO")
     * \\ Serializer\Groups(groups={"sonata_api_read","sonata_api_write","sonata_search"})
     *
     * @var int
     */
    protected $id;

    public function getId()
    {
        return $this->id;
    }

    /**
     * @ORM\PrePersist
     */
    public function prePersist(): void
    {
        parent::prePersist();
    }

    /**
     * @ORM\PreUpdate
     */
    public function preUpdate(): void
    {
        parent::preUpdate();
    }
}
