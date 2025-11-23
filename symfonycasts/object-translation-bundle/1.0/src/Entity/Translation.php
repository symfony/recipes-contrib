<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use SymfonyCasts\ObjectTranslationBundle\Model\Translation as BaseTranslation;

#[ORM\Entity]
class Translation extends BaseTranslation
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    public int $id;
}
