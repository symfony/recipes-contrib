<?php

namespace App\Entity\EasyMenu;

use Adeliom\EasyMenuBundle\Entity\MenuItemEntity as BaseMenuItemEntity;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="App\Repository\EasyMenu\MenuItemRepository")
 * @ORM\HasLifecycleCallbacks()
 * @ORM\Table(name="easy_menu__menus_items")
 */
class MenuItem extends BaseMenuItemEntity
{

}
