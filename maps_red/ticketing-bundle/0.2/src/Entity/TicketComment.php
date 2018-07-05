<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Maps_red\TicketingBundle\Entity\TicketComment as BaseTicketComment;

/**
 * @ORM\Entity(repositoryClass="App\Repository\TicketCommentRepository")
 */
class TicketComment extends BaseTicketComment
{
}
