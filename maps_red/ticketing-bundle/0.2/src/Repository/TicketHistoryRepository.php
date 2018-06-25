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

//    /**
//     * @return TicketHistory[] Returns an array of TicketHistory objects
//     */
    /*
    public function findByExampleField($value)
    {
        return $this->createQueryBuilder('t')
            ->andWhere('t.exampleField = :val')
            ->setParameter('val', $value)
            ->orderBy('t.id', 'ASC')
            ->setMaxResults(10)
            ->getQuery()
            ->getResult()
        ;
    }
    */

    /*
    public function findOneBySomeField($value): ?TicketHistory
    {
        return $this->createQueryBuilder('t')
            ->andWhere('t.exampleField = :val')
            ->setParameter('val', $value)
            ->getQuery()
            ->getOneOrNullResult()
        ;
    }
    */
}
