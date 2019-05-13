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
}
