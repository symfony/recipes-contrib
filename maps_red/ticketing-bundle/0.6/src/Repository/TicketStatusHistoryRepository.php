<?php

namespace App\Repository;

use App\Entity\TicketStatusHistory;
use Symfony\Bridge\Doctrine\RegistryInterface;
use Maps_red\TicketingBundle\Repository\TicketStatusHistoryRepository as BaseTicketStatusHistoryRepository;

/**
 * @method TicketStatusHistory|null find($id, $lockMode = null, $lockVersion = null)
 * @method TicketStatusHistory|null findOneBy(array $criteria, array $orderBy = null)
 * @method TicketStatusHistory[]    findAll()
 * @method TicketStatusHistory[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class TicketStatusHistoryRepository extends BaseTicketStatusHistoryRepository
{
    public function __construct(RegistryInterface $registry)
    {
        parent::__construct($registry, TicketStatusHistory::class);
    }
}
