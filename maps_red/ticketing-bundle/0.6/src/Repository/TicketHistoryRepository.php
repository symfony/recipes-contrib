<?php

namespace App\Repository;

use App\Entity\TicketHistory;
use Symfony\Bridge\Doctrine\RegistryInterface;
use Maps_red\TicketingBundle\Repository\TicketHistoryRepository as BaseTicketHistoryRepository;

/**
 * @method TicketHistory|null find($id, $lockMode = null, $lockVersion = null)
 * @method TicketHistory|null findOneBy(array $criteria, array $orderBy = null)
 * @method TicketHistory[]    findAll()
 * @method TicketHistory[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class TicketHistoryRepository extends BaseTicketHistoryRepository
{
    public function __construct(RegistryInterface $registry)
    {
        parent::__construct($registry, TicketHistory::class);
    }
}
