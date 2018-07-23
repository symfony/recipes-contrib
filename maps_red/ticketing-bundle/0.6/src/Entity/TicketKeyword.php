<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Maps_red\TicketingBundle\Entity\TicketKeyword as BaseTicketKeyword;

/**
 * @ORM\Entity(repositoryClass="App\Repository\TicketKeywordRepository")
 */
class TicketKeyword extends BaseTicketKeyword
{
}
