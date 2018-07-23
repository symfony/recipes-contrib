<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Maps_red\TicketingBundle\Entity\TicketHistory as BaseTicketHistory;

/**
 * @ORM\Entity(repositoryClass="App\Repository\TicketHistoryRepository")
 */
class TicketHistory extends BaseTicketHistory
{
}
