<?php

declare(strict_types=1);

namespace App\Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as MongoDB;
use JMS\Serializer\Annotation as Serializer;
use Sonata\MediaBundle\Document\BaseMedia;

/**
 * @MongoDB\Document
 * @MongoDB\HasLifecycleCallbacks
 */
class SonataMediaMedia extends BaseMedia
{
    /**
     * @MongoDB\Id()
     * @Serializer\Groups(groups={"sonata_api_read", "sonata_api_write", "sonata_search"})
     */
    protected $id;

    /**
     * @MongoDB\ReferenceMany(
     *     targetDocument="App\Document\SonataMediaGalleryHasMedia",
     *     mappedBy="media", cascade={"persist"}, orphanRemoval=false, sort={"position" = "ASC"}
     * )
     */
    protected $galleryHasMedias;

    /**
     * @MongoDB\Field(type="string", nullable=true)
     */
    protected $authorName;

    /**
     * @MongoDB\Field(type="boolean", nullable=true)
     */
    protected $cdnIsFlushable;

    /**
     * @MongoDB\Field(type="string", nullable=true)
     */
    protected $description;

    /**
     * @MongoDB\Field(type="string", nullable=true)
     */
    protected $copyright;

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
