<?php

namespace App\Entity\EasyMenu;

use Adeliom\EasyMenuBundle\Entity\MenuEntity as BaseMenuEntity;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="App\Repository\EasyMenu\MenuRepository")
 * @ORM\HasLifecycleCallbacks()
 * @ORM\Table(name="easy_menu__menus")
 */
class Menu extends BaseMenuEntity
{

}
