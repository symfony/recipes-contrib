<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use JMS\Serializer\Annotation as Serializer;
use Sonata\MediaBundle\Entity\BaseMedia;

/**
 * @ORM\Entity
 * @ORM\Table(name="media__media")
 * @ORM\HasLifecycleCallbacks
 */
class SonataMediaMedia extends BaseMedia
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue(strategy="AUTO")
     * @Serializer\Groups(groups={"sonata_api_read", "sonata_api_write", "sonata_search"})
     *
     * @var int
     */
    protected $id;

    /**
     * @ORM\OneToMany(
     *     targetEntity="App\Entity\SonataMediaGalleryHasMedia",
     *     mappedBy="media", cascade={"persist"}, orphanRemoval=false
     * )
     *
     * @var SonataMediaGalleryHasMedia[]
     */
    protected $galleryHasMedias;

    /**
     * Fix annotations if you use classification-bundle.
     *
     * // ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataClassificationCategory",
     *     cascade={"persist"}
     * )
     * // ORM\JoinColumn(name="category_id", referencedColumnName="id", onDelete="SET NULL")
     *
     * @var SonataClassificationCategory
     */
    protected $category;

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
