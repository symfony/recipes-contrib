<?php

namespace App\Entity\EasyAdmin;

use Adeliom\EasyAdminUserBundle\Entity\User as BaseUser;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="App\Repository\EasyAdmin\UserRepository")
 * @ORM\Table(name="easy_admin__user")
 * @ORM\HasLifecycleCallbacks()
 */
class User extends BaseUser
{

}
