<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use JMS\Serializer\Annotation as Serializer;
use Sonata\PageBundle\Entity\BaseBlock;

/**
 * @ORM\Entity
 * @ORM\Table(name="page__block")
 * @ORM\HasLifecycleCallbacks
 */
class SonataPageBlock extends BaseBlock
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue(strategy="AUTO")
     * // Serializer\Groups(groups={"sonata_api_read","sonata_api_write","sonata_search"})
     *
     * @var int
     */
    protected $id;

    /**
     * @ORM\OneToMany(
     *     targetEntity="App\Entity\SonataPageBlock",
     *     mappedBy="parent", cascade={"remove", "persist"}, orphanRemoval=true
     * )
     * @ORM\OrderBy({"position"="ASC"})
     *
     * @var SonataPageBlock[]
     */
    protected $children;

    /**
     * @ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataPageBlock",
     *     inversedBy="children"
     * )
     * @ORM\JoinColumn(name="parent_id", referencedColumnName="id", onDelete="CASCADE")
     *
     * @var SonataPageBlock
     */
    protected $parent;

    /**
     * @ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataPagePage",
     *     inversedBy="blocks", cascade={"persist"}
     * )
     * @ORM\JoinColumn(name="page_id", referencedColumnName="id", onDelete="CASCADE")
     *
     * @var SonataPagePage
     */
    protected $page;

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
