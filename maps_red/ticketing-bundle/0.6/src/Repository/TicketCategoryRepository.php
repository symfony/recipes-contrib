<?php

namespace App\Repository;

use App\Entity\TicketCategory;
use Symfony\Bridge\Doctrine\RegistryInterface;
use Maps_red\TicketingBundle\Repository\TicketCategoryRepository as BaseTicketCategoryRepository;

/**
 * @method TicketCategory|null find($id, $lockMode = null, $lockVersion = null)
 * @method TicketCategory|null findOneBy(array $criteria, array $orderBy = null)
 * @method TicketCategory[]    findAll()
 * @method TicketCategory[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class TicketCategoryRepository extends BaseTicketCategoryRepository
{
    public function __construct(RegistryInterface $registry)
    {
        parent::__construct($registry, TicketCategory::class);
    }

//    /**
//     * @return TicketCategory[] Returns an array of TicketCategory objects
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
    public function findOneBySomeField($value): ?TicketCategory
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
