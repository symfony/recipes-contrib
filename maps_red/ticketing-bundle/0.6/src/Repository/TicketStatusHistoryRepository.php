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

//    /**
//     * @return TicketStatusHistory[] Returns an array of TicketStatusHistory objects
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
    public function findOneBySomeField($value): ?TicketStatusHistory
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
