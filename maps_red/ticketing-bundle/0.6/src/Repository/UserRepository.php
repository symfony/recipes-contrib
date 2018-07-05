<?php

namespace App\Repository;

use App\Entity\User;
use Maps_red\TicketingBundle\Repository\UserRepository as BaseTicketRepository;
use Symfony\Bridge\Doctrine\RegistryInterface;
use Symfony\Bridge\Doctrine\Security\User\UserLoaderInterface;


/**
 * Class UserRepository
 *
 * @author François MATHIEU <francois.mathieu@livexp.fr>
 * @method User|null find($id, $lockMode = null, $lockVersion = null)
 * @method User|null findOneBy(array $criteria, array $orderBy = null)
 * @method User[] findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class UserRepository extends BaseTicketRepository implements UserLoaderInterface
{
    /**
     * UserRepository constructor.
     * @param RegistryInterface $registry
     */
    public function __construct(RegistryInterface $registry)
    {
        parent::__construct($registry, User::class);
    }

    /**
     * @param string $username
     * @return null|User
     */
    public function loadUserByUsername($username)
    {
        return $this->findByUsernameOrEmail($username);
    }

    /**
     * @param string $username
     * @return User|null
     */
    public function findByUsernameOrEmail($username)
    {
        return $this->createQueryBuilder('u')
            ->andWhere('UPPER(u.username) = :username OR UPPER(u.email) = :username')
            ->setParameter('username', strtoupper($username))
            ->setMaxResults(1)
            ->getQuery()
            ->getOneOrNullResult();
    }


}