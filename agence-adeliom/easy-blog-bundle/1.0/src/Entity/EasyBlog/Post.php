<?php

namespace App\Entity\EasyBlog;

use Adeliom\EasyBlogBundle\Entity\PostEntity as BasePostEntity;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="App\Repository\EasyBlog\PostRepository")
 * @ORM\Table(name="easy_blog__post")
 * @ORM\HasLifecycleCallbacks()
 */
class Post extends BasePostEntity
{

}
