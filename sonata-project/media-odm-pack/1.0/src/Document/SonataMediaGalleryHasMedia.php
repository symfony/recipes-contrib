<?php

declare(strict_types=1);

namespace App\Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as MongoDB;
use JMS\Serializer\Annotation as Serializer;
use Sonata\MediaBundle\Document\BaseGalleryHasMedia;

/**
 * @MongoDB\Document
 * @MongoDB\HasLifecycleCallbacks
 */
class SonataMediaGalleryHasMedia extends BaseGalleryHasMedia
{
    /**
     * @MongoDB\Id()
     * @Serializer\Groups(groups={"sonata_api_read", "sonata_api_write", "sonata_search"})
     */
    protected $id;

    /**
     * @MongoDB\ReferenceOne(
     *     targetDocument="App\Document\SonataMediaMedia",
     *     inversedBy="galleryHasMedias", cascade={"persist"}
     * )
     */
    protected $media;

    /**
     * @MongoDB\ReferenceOne(
     *     targetDocument="App\Document\SonataMediaGallery",
     *     inversedBy="galleryHasMedias", cascade={"persist"}
     * )
     */
    protected $gallery;

    public function getId(): ?int
    {
        return $this->id;
    }

    /**
     * @MongoDB\PrePersist
     */
    public function prePersist(): void
    {
        parent::prePersist();
    }

    /**
     * @MongoDB\PreUpdate
     */
    public function preUpdate(): void
    {
        parent::preUpdate();
    }
}
