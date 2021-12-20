<?php

namespace App\Entity\EasyPage;

use Adeliom\EasyPageBundle\Entity\Page as BasePage;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="App\Repository\EasyPage\PageRepository")
 * @ORM\HasLifecycleCallbacks()
 */
class Page extends BasePage
{

}
