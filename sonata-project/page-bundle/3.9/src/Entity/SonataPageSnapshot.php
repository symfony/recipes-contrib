<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use JMS\Serializer\Annotation as Serializer;
use Sonata\PageBundle\Entity\BaseSnapshot;

/**
 * @ORM\Entity
 * @ORM\Table(name="page__snapshot", indexes={
 *     @ORM\Index(
 *         name="idx_snapshot_dates_enabled", columns={"publication_date_start", "publication_date_end","enabled"
 *     })
 * })
 */
class SonataPageSnapshot extends BaseSnapshot
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
     * @ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataPageSite",
     *     cascade={"persist"}
     * )
     * @ORM\JoinColumn(name="site_id", referencedColumnName="id", onDelete="CASCADE")
     *
     * @var SonataPageSite
     */
    protected $site;

    /**
     * @ORM\ManyToOne(
     *     targetEntity="App\Entity\SonataPagePage",
     *     cascade={"persist"}
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
}
