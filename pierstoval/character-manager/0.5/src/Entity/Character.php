<?php

namespace App\Entity;

use Pierstoval\Bundle\CharacterManagerBundle\Entity\Character as BaseCharacter;
use Doctrine\ORM\Mapping as ORM;

class Character extends BaseCharacter
{
    /**
     * @var int
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    public function getId(): ?int
    {
        return $this->id;
    }
}
