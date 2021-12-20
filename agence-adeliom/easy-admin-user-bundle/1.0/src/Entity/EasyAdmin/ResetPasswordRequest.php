<?php

namespace App\Entity\EasyAdmin;

use Adeliom\EasyAdminUserBundle\Entity\ResetPasswordRequest as BaseResetPasswordRequest;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="App\Repository\EasyAdmin\ResetPasswordRequestRepository")
 * @ORM\Table(name="easy_admin__reset_password_request")
 * @ORM\HasLifecycleCallbacks()
 */
class ResetPasswordRequest extends BaseResetPasswordRequest
{

}
