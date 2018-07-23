<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Maps_red\TicketingBundle\Entity\TicketCategory as BaseTicketCategory;

/**
 * @ORM\Entity(repositoryClass="App\Repository\TicketCategoryRepository")
 */
class TicketCategory extends BaseTicketCategory
{
}
