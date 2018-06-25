<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Maps_red\TicketingBundle\Entity\TicketPriority as BaseTicketPriority;

/**
 * @ORM\Entity(repositoryClass="App\Repository\TicketPriorityRepository")
 */
class TicketPriority extends BaseTicketPriority
{
}
