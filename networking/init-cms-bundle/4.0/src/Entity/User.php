<?php

namespace App\Entity;

use Networking\InitCmsBundle\Entity\BaseUser;
use Doctrine\ORM\Mapping as ORM;

/**
 * User
 *
 * @ORM\Table(name="fos_user_user")
 * @ORM\Entity()
 */
class User extends BaseUser{

    /**
     * @var int
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * @var \Networking\InitCmsBundle\Model\AdminSettings
     * @ORM\Column(name="admin_settings", type="object", nullable=true)
     */
    protected $adminSettings;

}
