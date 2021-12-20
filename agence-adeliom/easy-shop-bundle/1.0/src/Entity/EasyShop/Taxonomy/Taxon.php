<?php

declare(strict_types=1);

namespace App\Entity\EasyShop\Taxonomy;

use Doctrine\ORM\Mapping as ORM;
use Sylius\Component\Core\Model\Taxon as BaseTaxon;
use Sylius\Component\Taxonomy\Model\TaxonTranslationInterface;

/**
 * @ORM\Entity
 * @ORM\Table(name="sylius_taxon")
 */
class Taxon extends BaseTaxon
{
    protected function createTranslation(): TaxonTranslationInterface
    {
        return new TaxonTranslation();
    }

    public static function getTranslationClass(): string
    {
        return TaxonTranslation::class;
    }

    public function getTree(string $separator = '/', bool $name = false): string
    {
        $tree = '';

        $current = $this;
        do {
            if ($name){
                $tree    = ((string) $current).$separator.$tree;
            }else{
                $tree    = $current->getSlug().$separator.$tree;
            }
            $current = $current->getParent();
        } while ($current);

        return trim($tree, $separator);
    }
}
