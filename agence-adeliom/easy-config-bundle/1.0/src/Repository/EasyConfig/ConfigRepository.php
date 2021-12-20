<?php

namespace App\Repository\EasyConfig;

use Adeliom\EasyConfigBundle\Repository\ConfigRepository as BaseConfigRepository;
use App\Entity\EasyConfig\Config;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method Config|null find($id, $lockMode = null, $lockVersion = null)
 * @method Config|null findOneBy(array $criteria, array $orderBy = null)
 * @method Config[]    findAll()
 * @method Config[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class ConfigRepository extends BaseConfigRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Config::class);
    }
}
