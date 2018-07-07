<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Maps_red\TicketingBundle\Entity\TicketStatus as BaseTicketStatus;

/**
 * @ORM\Entity(repositoryClass="App\Repository\TicketStatusRepository")
 */
class TicketStatus extends BaseTicketStatus
{
}
