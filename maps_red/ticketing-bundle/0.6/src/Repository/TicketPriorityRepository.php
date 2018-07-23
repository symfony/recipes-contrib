<?php

namespace App\Repository;

use App\Entity\TicketPriority;
use Symfony\Bridge\Doctrine\RegistryInterface;
use Maps_red\TicketingBundle\Repository\TicketPriorityRepository as BaseTicketPriorityRepository;

/**
 * @method TicketPriority|null find($id, $lockMode = null, $lockVersion = null)
 * @method TicketPriority|null findOneBy(array $criteria, array $orderBy = null)
 * @method TicketPriority[]    findAll()
 * @method TicketPriority[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class TicketPriorityRepository extends BaseTicketPriorityRepository
{
    public function __construct(RegistryInterface $registry)
    {
        parent::__construct($registry, TicketPriority::class);
    }
}
