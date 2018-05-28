<?php

declare(strict_types=1);

namespace App\Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as MongoDB;
use JMS\Serializer\Annotation as Serializer;
use Sonata\MediaBundle\Document\BaseGallery;

/**
 * @MongoDB\Document
 * @MongoDB\HasLifecycleCallbacks
 */
class SonataMediaGallery extends BaseGallery
{
    /**
     * @MongoDB\Id()
     * @Serializer\Groups(groups={"sonata_api_read", "sonata_api_write", "sonata_search"})
     */
    protected $id;

    /**
     * @MongoDB\ReferenceMany(
     *     targetDocument="App\Document\SonataMediaGalleryHasMedia",
     *     mappedBy="gallery", cascade={"persist"}, orphanRemoval=false, sort={"position" = "ASC"}
     * )
     */
    protected $galleryHasMedias;

    public function getId()
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
