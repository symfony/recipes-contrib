<?php
namespace App\Entity;

use Doctrine\Common\Collections\ArrayCollection;
use Gedmo\Mapping\Annotation as Gedmo;
use Networking\InitCmsBundle\Entity\BasePage;
use Doctrine\ORM\Mapping as ORM;
use Networking\InitCmsBundle\Model\ContentRoute;

/**
 *
 * @author Yorkie Chadwick <y.chadwick@networking.ch>
 *
 * @ORM\Entity
 * @ORM\Table(name="page",
 *     uniqueConstraints={@ORM\UniqueConstraint(name="path_idx", columns={
 *         "path", "locale"
 *     })}
 * )
 * @ORM\HasLifecycleCallbacks()
 */
class Page extends BasePage{

    /**
     * @var integer $id
     *
     * @ORM\Column(type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="IDENTITY")
     */
    protected $id;

    /**
     * @var ContentRoute
     * @ORM\OneToOne(
     *      targetEntity = "Networking\InitCmsBundle\Entity\ContentRoute",
     *      cascade={"remove", "persist"}
     * )
     * @ORM\JoinColumn(name="content_route_id", referencedColumnName="id")
     */
    protected $contentRoute;

    /**
     * @ORM\OneToMany(targetEntity="Networking\InitCmsBundle\Entity\LayoutBlock",
     *      mappedBy="page",
     *      cascade={"remove", "persist"},
     *      orphanRemoval=true
     * )
     * @ORM\OrderBy({"sortOrder" = "ASC"})
     */
    protected $layoutBlock;

    /**
     * @ORM\OneToMany(targetEntity="Networking\InitCmsBundle\Entity\MenuItem",
     *      mappedBy="page",
     *      cascade={"remove"},
     *      orphanRemoval=true
     * )
     */
    protected $menuItem;

    /**
     * @ORM\OneToMany(targetEntity="Networking\InitCmsBundle\Entity\PageSnapshot",
     *      mappedBy="page",
     *      cascade={"remove"},
     *      orphanRemoval=true
     * )
     * @ORM\OrderBy({"version" = "DESC"})
     */
    protected $snapshots;

    /**
     * @ORM\OneToMany(targetEntity="App\Entity\Page",
     *      mappedBy="parent"
     * )
     */
    protected $children;

    /**
     * @var Page
     * @ORM\ManyToOne(targetEntity="App\Entity\Page" )
     * @ORM\JoinColumn(name="alias_id", referencedColumnName="id", onDelete="SET NULL")
     */
    protected $alias;

    /**
     * @var Page
     * @ORM\ManyToOne(targetEntity="App\Entity\Page", inversedBy="children", cascade="persist" )
     * @ORM\JoinColumn(name="parent_id", referencedColumnName="id", onDelete="SET NULL")
     * @Gedmo\TreeParent
     */
    protected $parent;

    /**
     * @var ArrayCollection $originals
     * @ORM\ManyToMany(
     *      targetEntity="App\Entity\Page",
     *      inversedBy="translations",
     *      cascade={"persist"}
     * )
     * @ORM\JoinTable(
     *      name="page_translation",
     *      joinColumns={
     *          @ORM\JoinColumn(name="translation_id", referencedColumnName="id")
     *      },
     *      inverseJoinColumns={
     *          @ORM\JoinColumn(name="original_id", referencedColumnName="id")
     *      }
     * )
     */
    protected $originals;

    /**
     * @var ArrayCollection $translations
     * @ORM\ManyToMany(
     *      targetEntity="App\Entity\Page",
     *      mappedBy="originals",
     *      cascade={"persist"}
     * )
     */
    protected $translations;
}
