<?php

namespace App\Repository;

use App\Entity\TicketComment;
use Symfony\Bridge\Doctrine\RegistryInterface;
use Maps_red\TicketingBundle\Repository\TicketCommentRepository as BaseTicketCommentRepository;

/**
 * @method TicketComment|null find($id, $lockMode = null, $lockVersion = null)
 * @method TicketComment|null findOneBy(array $criteria, array $orderBy = null)
 * @method TicketComment[]    findAll()
 * @method TicketComment[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class TicketCommentRepository extends BaseTicketCommentRepository
{
    public function __construct(RegistryInterface $registry)
    {
        parent::__construct($registry, TicketComment::class);
    }
}
