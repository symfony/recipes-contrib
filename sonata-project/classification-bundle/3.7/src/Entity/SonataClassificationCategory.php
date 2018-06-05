<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use JMS\Serializer\Annotation as Serializer;
use Sonata\ClassificationBundle\Entity\BaseCategory;
use Sonata\MediaBundle\Model\MediaInterface;
use Symfony\Component\Validator\Constraints as Assert;

/**
 * @ORM\Entity
 * @ORM\Table(name="classification__category")
 * @ORM\HasLifecycleCallbacks
 */
class SonataClassificationCategory extends BaseCategory
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue(strategy="AUTO")
     * // Serializer\Groups(groups={"sonata_api_read", "sonata_api_write", "sonata_search"})
     *
     * @var int
     */
    protected $id;

    /**
     * @ORM\OneToMany(
     *     targetEntity="App\Entity\SonataClassificationCategory",
     *     mappedBy="parent", cascade={"persist"}, orphanRemoval=true
     * )
     * @ORM\OrderBy({"position"="ASC"})
     *
     * @var SonataClassificationCategory[]
     */
    protected $children;

    /**
     * @ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataClassificationCategory",
     *     inversedBy="children", cascade={"persist", "refresh", "merge", "detach"}
     * )
     * @ORM\JoinColumn(name="parent_id", referencedColumnName="id", onDelete="CASCADE")
     *
     * @var SonataClassificationCategory
     */
    protected $parent;

    /**
     * @ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataClassificationContext",
     *     cascade={"persist"}
     * )
     * @ORM\JoinColumn(name="context", referencedColumnName="id", nullable=false)
     * @Assert\NotNull()
     *
     * @var SonataClassificationContext
     */
    protected $context;

    public function getId()
    {
        return $this->id;
    }

    final public function setMedia(MediaInterface $media = null)
    {
        parent::setMedia($media);
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
