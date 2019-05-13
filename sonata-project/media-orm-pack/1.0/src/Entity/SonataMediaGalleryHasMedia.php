<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use JMS\Serializer\Annotation as Serializer;
use Sonata\MediaBundle\Entity\BaseGalleryHasMedia;

/**
 * @ORM\Entity
 * @ORM\Table(name="media__gallery_media")
 * @ORM\HasLifecycleCallbacks
 */
class SonataMediaGalleryHasMedia extends BaseGalleryHasMedia
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
     * @ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataMediaMedia",
     *     inversedBy="galleryHasMedias", cascade={"persist"}
     * )
     * @ORM\JoinColumn(name="media_id", referencedColumnName="id", onDelete="CASCADE")
     *
     * @var SonataMediaMedia
     */
    protected $media;

    /**
     * @ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataMediaGallery",
     *     inversedBy="galleryHasMedias", cascade={"persist"}
     * )
     * @ORM\JoinColumn(name="gallery_id", referencedColumnName="id", onDelete="CASCADE")
     *
     * @var SonataMediaGallery
     */
    protected $gallery;

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
