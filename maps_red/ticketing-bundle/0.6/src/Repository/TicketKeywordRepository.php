<?php

namespace App\Repository;

use App\Entity\TicketKeyword;
use Symfony\Bridge\Doctrine\RegistryInterface;
use Maps_red\TicketingBundle\Repository\TicketKeywordRepository as BaseTicketKeywordRepository;

/**
 * @method TicketKeyword|null find($id, $lockMode = null, $lockVersion = null)
 * @method TicketKeyword|null findOneBy(array $criteria, array $orderBy = null)
 * @method TicketKeyword[]    findAll()
 * @method TicketKeyword[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class TicketKeywordRepository extends BaseTicketKeywordRepository
{
    public function __construct(RegistryInterface $registry)
    {
        parent::__construct($registry, TicketKeyword::class);
    }
}
