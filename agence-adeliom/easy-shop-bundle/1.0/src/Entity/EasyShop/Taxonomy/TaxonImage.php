<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Taxonomy;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\TaxonImage as BaseTaxonImage;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_taxon_image")
 */
class TaxonImage extends BaseTaxonImage
{
}
