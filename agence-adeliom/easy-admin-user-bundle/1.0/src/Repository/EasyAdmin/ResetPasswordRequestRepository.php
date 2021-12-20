<?php

namespace App\Repository\EasyAdmin;

use Adeliom\EasyAdminUserBundle\Repository\ResetPasswordRequestRepository as BaseResetPasswordRequestRepository;
use App\Entity\EasyAdmin\ResetPasswordRequest;
use Doctrine\Persistence\ManagerRegistry;

class ResetPasswordRequestRepository extends BaseResetPasswordRequestRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, ResetPasswordRequest::class);
    }
}
