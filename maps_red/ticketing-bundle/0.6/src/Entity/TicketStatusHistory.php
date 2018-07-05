<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Maps_red\TicketingBundle\Entity\TicketStatusHistory as BaseTicketStatusHistory;

/**
 * @ORM\Entity(repositoryClass="App\Repository\TicketStatusHistoryRepository")
 */
class TicketStatusHistory extends BaseTicketStatusHistory
{
}
