<?php
/**
 * This file is part of the init_cms_sandbox package.
 *
 * (c) net working AG <info@networking.ch>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
 

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
